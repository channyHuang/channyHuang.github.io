### 物理相关文件介绍

```C++
 ColliderConfig文件 
 // Object相关碰撞形状的配置解析，生成碰撞形状的描述结构体ColliderConfig
```

```C++
 BasePart文件 
 // 零件物理属性绑定以及设置，零件物理相关的物理

 PrimitiveBodyComponent文件
 /* 物理组件，主要职责是
    1、绑定游戏对象到physx的shape上
    2、管理instanceBody
    3、操作instanceBody的组件
    4、对外暴露的物理api接口
 */ 

  InstanceBodyPhysx文件
 /*
    1、操作physx对象的中间层
 */ 

   CollisionShapeProducer文件
 /* 
    1、根据instance节点类型生产physxshape形状的类
 */ 

   PhysicsWorldPhysx文件
 /* 
    1、物理世界的初始化、physx回调、碰撞组、碰撞查询api接口
 */ 

   Physics_Register文件
 /* 
    1、导api到lua
 */ 
 
   PhysxSDK文件
 /* 
    1、physx的一些设置，包括error回调、性能分析
 */ 

    ContactNotifyHelper文件
 /* 
    1、事件的管理和派发
    2、触发的事件
        entityTouchPartBegin、part_touch_entity_begin、
        part_touch_part_begin、entityTouchPartEnd、
        part_touch_entity_end、part_touch_part_end、entityTouchPartUpdate
 */ 
 
```




### entity推零件
```C++
void Entity::solveTouch()
		auto dir = testMotion.normalizedCopy();
		map->getPhysxWorld()->sweepTest(primitiveBodyComponent->getInstanceBody(), from, dir, testMotion.len() * 1.2f, callback, 0.f);
		auto entitySpeed = getSpeed();
		for (const auto& ob : callback._results)
		{
			auto instance = Instance::getByInstanceId(ob._target.getInstanceID());
			LordAssert(instance);
			auto part = instance_cast<BasePart>(instance);
			if (!part)
				continue;
			auto touchPos = ob._collidePos - from.getOrigin();
			auto touchDir = (ob._collidePos - from.getOrigin()).normalizedCopy();
			auto curV = part->getCurLineVelocity();
			float projection = curV.len() / entitySpeed;
			if (projection < VELOCITY_SCALE * 1.f)
			{
				/// 当base物体大于人的速度不需要推动
				if (abs(ob._normalOnHitObject.y) < 0.5f)
				{
					touchPos.y = 0.f;
				}
				auto force = prop.pushForce * -ob._normalOnHitObject * 10.f;
				part->applyForce(force, touchPos);
				//world->getLuaEngine().call("entity_event", this, "entityHitPart", part, ob._collidePos, ob._normalOnHitObject, ob._distance);
			}
		}


/*
    如果推东西不够持续，断断续续可以看下callback._results是不是没有每次检测到，再看是不是被什么条件跳过
    part->applyForce(force, touchPos);这个可以根据需要更换成冲量
    向下给力，可能会导致物体穿到地底下去
*/
```

### 物理世界和游戏世界交互
#### 物理shape对象绑定游戏对象
``` C++
	BasePart::BasePart()
	{
		getPrimitiveBody()->setOwnerUserData(this);
    }

    void InstanceBodyPhysx::setShapes(LORD::vector<BPhysicsShapeHandle>& freshShapes)
	{
		for (auto shape : freshShapes) {
			BPhysicsCmdPhysx::SetShapeUserData(shape, &_selfUserData);
		}
    }

    /*
        1、shape的userData绑定了InstanceBodyPhysx对象
        2、InstanceBodyPhysx持有BasePart对象的指针
        3、因此能通过shape找到BasePart对象的指针
        4、可以看getInstanceBodyByActorUserData函数
    */
```

#### 物理位置结果同步到游戏对象上
``` C++
    void PhysicsWorldPhysx::tick()
	{
		PROFILE_CPU("PhysicsWorldPhysx:tick");
		auto setLogicTransform = [](InstanceBodyPhysx* instanceBodyPhysx, const PxTransform& pxTr)
		{
			if (auto instance = getInstance(instanceBodyPhysx))
			{
				if (auto part = instance->castTo<BasePart>())
				{
					auto tr = PxTransform2Transform(pxTr);
					part->setMove(tr, 1);
				}
			}
		};
		auto tickRate = WorldConfig::Instance()->physicsTickRate;
		if (tickRate <= 0)
			tickRate = 60;
		const int tickNum = (tickRate - 1) / GAME_FPS + 1; // tickRate ÷ GAME_FPS 向上取整;
		const float interval = 1.f / tickRate;
		{
			PROFILE_CPU("doPhysxTick");
			for (int i = 0; i < tickNum; i++)
			{
				_pxScene->simulate(interval);
				_pxScene->fetchResults(true);
			}
		}
		PxU32 nbActiveActors;
		PxActor** activeActors = _pxScene->getActiveActors(nbActiveActors);
		{
			PROFILE_CPU("processLogicTransform");
			for (PxU32 i = 0; i < nbActiveActors; ++i)
			{
				auto actor = static_cast<PxRigidActor*>(activeActors[i]);
				auto pxTr = actor->getGlobalPose();
				auto userData = actor->userData;
				if (auto instanceBodyPhysx = getInstanceBodyByActorUserData(userData))
				{
					setLogicTransform(instanceBodyPhysx, pxTr);

					Transform parentGlobalTr = PxTransform2Transform(pxTr);
					auto& poseInfos = instanceBodyPhysx->getWeldBodyPoseInfo();
					for (auto& poseInfoItem : poseInfos)
					{
						setLogicTransform(poseInfoItem.first, Transform2PxTransform(parentGlobalTr * poseInfoItem.second));
					}
				}
			}
		}
	}

    /*
        setLogicTransform将物理数据设置回游戏上，只有刚体参与物理解算后，才需要设置回游戏
    */
```

#### 游戏对象位置设置回物理
``` C++
    /* 零件 */
    void BasePart::handleNotification(NodeEvents event)
    {
        PROFILE_CPU("BasePart::handleNotification");
        auto body = getPrimitiveBody();
        switch (event)
        {
        case NodeEvents::NOTIFICATION_TRANSFORM_CHANGED:
            if (body)
            {
                // 更新物理位置
                body->setColliderTransform(getWorldTransform());
            }
        }
    }

    /* 当零件通过非物理的方式驱动位置的时候，需要更新物理的位置 */


    /* entity dropitem missle 等等继承object的*/
	void Object::move(const LORD::Vector3& displacement)
	{
		if (displacement == Vector3::ZERO)
		{
			return;
		}
		if (!displacement.isFinite())
		{
			LordLogError("move with invalid displacement: %f,%f,%f", displacement.x, displacement.y, displacement.z);
			std::abort();
		}
		if (auto body = getPrimitiveBody())
		{
			body->setColliderPosition(displacement + getPosition());
		}
		lastMoveDir = displacement.normalizedCopy();
		setNeedUpdateAABB();
		MovableNode::setPosition(displacement + getPosition());
	}
    /* 通过setColliderPosition更改物理的transform ，这里只有position */

    bool Object::tryRotate(float yaw, float pitch, float roll, bool forceRotate)
    {
        setColliderTransform
    }
    /* rotation 通过tryRotate 的setColliderTransform更改旋转角度*/
```

#### 物理引擎内置的事件派发
``` C++
    BPxSimulationEventCallback回调函数
	void onContact(const PxContactPairHeader& /*pairHeader*/, const PxContactPair* pairs, PxU32 count)
    {
        ContactNotifyHelper::onContactBegin(&pair);
		ContactNotifyHelper::onContactEnd(&pair);
        ContactNotifyHelper::onContactStay(&pair);
    }
    开始接触事件、停止接触事件、持续接触事件

    ContactNotifyHelper文件
    /*
        1、对碰撞对信息进行管理，并统一在tick里进行派发
        2、因为1次逻辑tick里面执行了3次物理的tick，所以这里持续接触会发生3次
        3、派发到lua的事件有entityTouchPartBegin、part_touch_entity_begin、
        part_touch_part_begin、entityTouchPartEnd、
        part_touch_entity_end、part_touch_part_end、entityTouchPartUpdate
    */

```


#### entity事件
``` C++
    /*
        entity的事件在latetick里面触发
    */
```

#### object的碰撞生成
``` C++
    /*
        必须先有ColliderConfig
        entity读取配置生成碰撞描述信息ColliderConfig
            - ColliderConfig::ExtractConfig(table, p.collider);
        
    */

    void Object::setCollider(const ColliderConfig& config, const LORD::Vector3& pos)
    {
        setNeedUpdateAABB();
		colliderScaling = Vector3::ONE;
		overrideColliderConfig = config;
		if (auto primitiveBody = getPrimitiveBody())
		{
			auto tr = primitiveBody->getColliderTransform();
			tr.setOrigin(pos);
			primitiveBody->setColliderTransform(tr);
			primitiveBody->updateShape();
		}
    }



    /* 使用setCollider 函数去调用updateShape生成对应的physx shape */
	bool CollisionShapeProducer::makeShape(Object* object, InstanceBodyInterface* body, LORD::vector<BPhysicsShapeHandle>& outShapeHandles)
	{
		if (auto entity = object->entity())
		{
			return makeShapeEntity(entity, body, outShapeHandles);
		}
		return makeShapeObject(object, body, outShapeHandles);
	}

    bool CollisionShapeProducer::makeShapeEntity(Entity* object, InstanceBodyInterface* body, LORD::vector<BPhysicsShapeHandle>& outShapeHandles)
	{
		if (object->config->rideOnCombineCollision)
		{
			auto parentInverse = Transform2PxTransform(object->getPrimitiveBody()->getColliderTransform().inverse());
			for (auto childId : object->getRideOnChilds())
			{
				if (auto child = object->world->getEntity(childId))
				{
					LORD::vector<BPhysicsShapeHandle> shapes;
					makeShapeEntity(child, body, shapes);

					auto childTransform = Transform2PxTransform(child->getPrimitiveBody()->getColliderTransform());
					auto relativeTransform = parentInverse * childTransform;
					for (auto&& handle : shapes)
					{
						auto childTransform = handle._pxShape->getLocalPose();
						handle._pxShape->setLocalPose(relativeTransform * childTransform);
					}

					outShapeHandles.insert(outShapeHandles.end(), shapes.begin(), shapes.end());
				}
			}
		}
		return makeShapeObject(object, body, outShapeHandles);
	}

    /* 当骑乘的时候使用rideOnCombineCollision将多个单位的碰撞shape合并到一个碰撞actor上*/


	void Object::scaleObject(const Vector3& scale)
	{
		scaleCollider(scale);
		setActorScale(scale);
	}

    /* 如果有碰撞缩放，得调用scaleCollider */
```

#### 零件的碰撞生成
``` C++
    bool CollisionShapeProducer::makeShape(InstanceBodyInterface* body, LORD::vector<BPhysicsShapeHandle>& outShapeHandles)
	{
		// 刷新形状
		bool isCustomShape = false;
		if (auto instance = getInstance(body))
		{
			if (auto basePart = instance->castTo<BasePart>())
			{
				makeShape(basePart, body, outShapeHandles);
			}
			else if (auto object = instance->castTo<Object>())
			{
				makeShape(object, body, outShapeHandles);

			}
			else
			{
				isCustomShape = true;
			}
		}
    }

	bool CollisionShapeProducer::makeShape(Part* part, InstanceBodyInterface* body, LORD::vector<BPhysicsShapeHandle>& outShapeHandles)
	{
		// 刷新 
		Vector3 scale = Vector3::ONE;
		Shapes shape = part->getShape();
		ShapeParam param;
		param._material = body->getMaterialHandle();
		switch (shape)
		{
			case Shapes::CUBE:
			{
				param._geometry = make_shared<::physx::PxBoxGeometry>(U2PxVector3(scale * 0.5));;
				break;
			}
			case Shapes::SPHERE:
			{
				auto radius = scale.y / 2;
				param._geometry = make_shared <::physx::PxSphereGeometry>(radius);;
				break;
			};
			case Shapes::CYLINDER:
			{
				param._geometry = CollisionBrushBuilder::Instance()->createCylinderConvexGeometry(scale.y, scale.x)->_geometry;
				break;
			};
			case Shapes::CYLINDER_X:
			{
				// 不支持
				LordAssert(false);
				break;
			};
			case Shapes::CYLINDER_Z:
			{
				// 不支持
				LordAssert(false);
				break;
			};
			case Shapes::CIRCULAR_CONE:
			{
				param._geometry = CollisionBrushBuilder::Instance()->createConeConvexGeometry(scale.y, scale.x)->_geometry;
				break;
			};
		}
		BPhysicsCmdPhysx::CreateShape(param, outShapeHandles);
		return true;
	}

    makeShape出来的形状必须保证缩放是原始模型尺寸，Vector3 scale = Vector3::ONE;
    在makeShape会有统一scaleShape的地方
```

#### 如何添加编辑器可点击节点
``` C++
    参考EffectPartClient
```

#### 如何扩展基础形状
```C++
bool CollisionShapeProducer::makeShape(Part* part, InstanceBodyInterface* body, LORD::vector<BPhysicsShapeHandle>& outShapeHandles)
{
	param._geometry = CollisionBrushBuilder::Instance()->createCylinderConvexGeometry(scale.y, scale.x)->_geometry;
    param._geometry = CollisionBrushBuilder::Instance()->createConeConvexGeometry(scale.y, scale.x)->_geometry;

}

/*
    1、查考createConeConvexGeometry和createCylinderConvexGeometry
    2、程序生成点去逼近形状，需要保证尺寸为1*1*1的大小
*/
```

#### 零件凸化
 - 凸化原因
   - 凹的网格physx不支持移动碰撞检测，不能主动检测，只能被动检测
   - 性能消耗大
 - 凸化库
   - vhacd
   - hacd
   - quickHull
 - 缺陷
   - 性能消耗比较大，一般需要离线生成
  
- 引擎内的凸化条件
  - 继承于CSGShape的派生类，碰撞精度属性（collisionFidelity）
    - 碰撞精度PRECISE_CONVEX_DECOMPOSITION需要凸化
    - 碰撞精度DEFAULT并且非锚定的情况

- 如果是开编辑器凸化太多，导致卡顿，大概是编辑器数据有问题  
``` C++
    参考EffectPartClient
```

#### 玩家移动控制器
``` C++
    void PlayerControl::tick()
```


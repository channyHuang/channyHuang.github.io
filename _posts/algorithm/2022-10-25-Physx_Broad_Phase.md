---
layout: default
title: Physx Broad Phase
categories:
- Algorithm
- Lib
tags:
- Game
---
//Description: Physx Broad Phase

//Create Date: 2022-10-25 16:02:39

//Author: channy

# 概述  
physx中的broad phase笔记

# BroadPhase 三种算法  
* SAP 适用于动态物体较少时
* MBP (multi-box pruning) 需要指定场景边界，适用于大场景小运动距离
* ABP 适用于动态物体较多时，为physx默认算法

三种算法入口均统一位于AABBManager.finalizeUpdate的mBroadPhase.update中

mBroadPhase.update 输入参数BroadPhaseUpdateData中包含了add/remove/update的object的handle索引，只存索引，即mBoxBounds的下标，实际数据在mBoxBounds中，即AABBManager.mBoundsArray。mGroup记录分组，在同一组的object不检测两两是否有相交。mContactDistance用于计算外轮廓，输出BroadPhasePair。

```c++
	BroadPhaseUpdateData(
		const ShapeHandle* created, const PxU32 createdSize, 
		const ShapeHandle* updated, const PxU32 updatedSize, 
		const ShapeHandle* removed, const PxU32 removedSize, 
		const PxBounds3* boxBounds, const Bp::FilterGroup::Enum* boxGroups,
#ifdef BP_FILTERING_USES_TYPE_IN_GROUP
		const bool* lut,
#endif
		const PxReal* boxContactDistances, const PxU32 boxesCapacity,
		const bool stateChanged) :
		mCreated		(created),
		mCreatedSize	(createdSize),
		mUpdated		(updated),
		mUpdatedSize	(updatedSize),
		mRemoved		(removed),
		mRemovedSize	(removedSize),
		mBoxBounds		(boxBounds),
		mBoxGroups		(boxGroups),
#ifdef BP_FILTERING_USES_TYPE_IN_GROUP
		mLUT			(lut),
#endif
		mContactDistance(boxContactDistances),
		mBoxesCapacity	(boxesCapacity),
		mStateChanged	(stateChanged)
	{
	}
```

## ABP  （Automatic Box Pruning）
* BroadPhaseABP.update
	* setUpdateData 有优化点：可能存在不必要的copy
		* removeObjects 对remove中的每一个handle，调用ABP.removeObject。其中handle虽然是ShapeHandle，实际上是BoundHandle
			* ABP.removeObject 根据handle取到mABP_Objects中的object，只把mInToOut_Sleeping/mInToOut_Updated的index标记为INVALID_ID 
		* addObjects
			* ABP.addDynamicObjects
				* BoxManager.addObjects 在mInToOut_Updated中分batch增加index，先把batch的index填充，再批量加入到mInToOut_Updated中
		* updateObjects 从sleep移到update中
		* ABP.Region_prepareOverlaps //static、dynamic、kinematic三个BoxManager
			* prepareData 遍历BoxManager中的每个物体，更新bounding，对新加入的sleeping物体合并排序，存储在mInToOut_Sleeping中，及对update也进行排序存储在mInToOut_Updated中
				* purgeRemovedFromSleeping 删除已经remove的sleeping的物体
				* RadixSort.sort
			* notifyStaticChange // do nothing here
	* update
		* ABP.findOverlaps
			* Region_findOverlaps 查找碰撞对(ABP_PairManager/PairManagerData.mNbActivePairs)
				* Region_prepareOverlaps
				* findAllOverlaps //static-dynamic、dynamic-dynamic
					* doCompleteBoxPruning_ //dynamic-dynamic
						* doBipartiteBoxPruning_Leaf //sleeping-active dynamic, 判断AABB相交
							* boxPruningKernel
						* doCompleteBoxPruning_Leaf
							* outputPair 赋值index给ABP的ABP_PairManager.mInToOut/ABP_MM
					* doBipartiteBoxPruning_Leaf 有优化点：bit冗余 // acitve dynamic - static, dynamic - kinematic
	* postUpdate
		* ABP.finalize
			* ABP_PairManager.computeCreatedDeletedPairs copy新增和删除的Pairs到BroadPhaseABP.mCreated/mDeleted，处理碰撞开始/持续/分离期。没有标记新增和更新的，除了可能是删除的pair外，还可能是sleeping的pair。MBP与ABP的不同点在于多了一个decodeHandle_Index获取实际index的步骤。除了persistentPairs，只有此处会调用PairManager.removePair

## SAP （Sweeping Plane Algorithm）
[SAP](./imageFormat/SAP.png)
* BroadPhaseSap.update
	* SapUpdateWorkTask
		* update
			* batchUpdate (BroadPhaseBatchUpdateWorkTask，对每个axis，输出BroadPhasePair保存到每个batch中)
				* batchUpdateFewUpdates
	* SapPostUpdateWorkTask
		* postUpdate addPair到SapPairManager中，保存了所有相交的Box-Box对
			* batchCreate 有优化点：把静态/动态物体分开可以加速
				* ComputeSortedLists 
				* performBoxPruningNewNew
				* performBoxPruningNewOld
			* ComputeCreatedDeletedPairsLists

1. 每一帧的碰撞检测相互独立，没有利用好帧的连续性，算法复杂度高。
2. 投影轴的选取影响性能

## MBP  （Multi Box Pruning）
[MBP](./imageFormat/MSAP.png)
把场景分成多个区域（region），每个区域上实现SAP（即M-SAP）/BP，考虑边界物体

BroadPhaseMBP.update
	* setUpdateData 输入同上
		* removeObjects 对removed中的每一个handle索引，调用MBP.removeObject。这里的mMapping数组，是从handle到MBP_Handle的映射。MBP_Handle为PxU32类型，最后一位是isStatic标志，倒数第2位是flipFlop标志，其它存储objectIndex,即MBP.mMBP_Objects中的索引。
			* MBP.removeObject 从每个region中删除物体。nbHandles表示该物体跨越了多少个region
				* purgeHandles  若nbHandles == 1，直接存放在MBP_Object的mHandle变量中; 若nbHandles > 1，即一个MBP_Object跨了多个region，则放在二维数组mHandles中。即，基本设计思路为：mHandle[nregion]，删除后下次需要nregion个region时，直接从mFirstFree[nregion]中查找可用空间，空闲空间的链表管理法。
				* setBitChecked 设置更新标识
		* addObjects （1）计算物体的aabb，存储到mMBP_Objects中；boundsXYZ即为mBoxBounds；（2）遍历每个region，如果该region与物体相交，就调用region的addObject；（3）storeHandles；（4）设置其它标记
			* MBP.addObject 检查mFirstFreeIndex，存在则找到mMBP_Objects中对应的位置，即上次remove留下的空位；不存在则直接在后面增加；计算MBPObjectHandle返回并存入mMapping。RegionHandle中mHandle记录在mObjects中的索引，mInternalBPHandle记录mRegions中的索引，MBP层和region层
			* storeHandles 对应于purgeHandles，一add一remove
		* updateObjects
			* MBP.updateObject 大多数情况下只与一个region相交，重新计算与所有region的相交情况，比较决定是update还是remove
				* setBitChecked 给后续更新逻辑使用
		* prepareOverlaps 每个region进行更新
			* Region.prepareOverlaps 排序
				* staticSort 对静态物体排序，把需要排序的按mMinX值进行sort，再合并到不需要排序的数据中
				* preparePruning 对动态物体（active的和sleep的）排序
				* prepareBIPPruning
	* update (MBPUpdateWorkTask)
		* MBP.findOverlaps
			* Region.findOverlaps
				* doCompleteBoxPruning 检测sleeping-dynamic，遍历每个活动的物体A，找出与A(在x轴上)相交的一个或多个sleeping物体; 遍历每个sleeping物体B，找出与B(在x轴上)相交的一个或多个活动的物体
				* doBipartiteBoxPruning 检测dynamic
	* postUpdate (MBPPostUpdateWorkTask)
		* finalize
			* MBP_PairManager.computeCreatedDeletedPairs

Region.addObject （1）寻找空位；每个region都有一个mObjects（MBPEntry）数组，其中mIndex对应mObjects，mMBPHandle对应上层MBP（2）静态物体增加到mStaticBoxes中；mInToOut_Static上下层索引转换（3）动态物体增加到mDynamicBoxes中；（4）动态物体调整位置
	* MTF 保证mNbUpdatedBoxes与mObjects[handle].mIndex位置相同，因为每次simulate后mNbUpdatedBoxes会被置0


# reference
[PhysX](https://github.com/NVIDIAGameWorks/PhysX)

[PhysX doc](https://gameworksdocs.nvidia.com/PhysX/4.1/documentation/physxguide/Manual/Introduction.html)

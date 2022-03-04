---
layout: default
title: Roblox_Physice_Solver.md
categories:
- Game
tags:
- Game
---
//Description: [译][Improving Simulation and Performance with an Advanced Physics Solver](https://blog.roblox.com/2020/08/improving-simulation-performance-advanced-physics-solver/)  
使用高级物理求解器改善仿真和性能

//Create Date: 2022-03-04 18:31:39

//Author: channy

# 概述  

In mid-2015, Roblox unveiled a major upgrade to its physics engine: the Projected Gauss-Seidel (PGS) physics solver. For the first year, the new solver was optional and provided improved fidelity and greater performance compared to the previously used spring solver.

2015年中期，Roblox发布了对其物理引擎的重大升级：Projected Gauss-Seidel(PGS)物理求解器。
第一年，新的求解器是可选的，与以前使用的弹簧求解器相比，它提供了更高的保真度和更高的性能。

In 2016, we added support for a diverse set of new physics constraints, incentivizing developers to migrate to the new solver and extending the creative capabilities of the physics engine. Any new places used the PGS solver by default, with the option of reverting back to the classic solver.

在2016年，我们增加了对各种新物理约束的支持，从而激励开发人员迁移到新的求解器，并扩展了物理引擎的创造能力。 默认情况下，所有新场景都使用PGS求解器，并可以选择还原为经典求解器。

We ironed out some stability issues associated with high mass differences and complex mechanisms by the introduction of the hybrid LDL-PGS solver in mid-2018. This made the old solver obsolete, and it was completely disabled in 2019, automatically migrating all places to the PGS.

通过在2018年中期引入混合LDL-PGS求解器，我们消除了一些与高质量差异和复杂机制相关的稳定性问题。 这使旧的求解器过时了，并于2019年被完全禁用，自动将所有场景迁移到PGS。

In 2019, the performance was further improved using multi-threading that splits the simulation into jobs consisting of connected islands of simulating parts. We still had performance issues related to the LDL that we finally resolved in early 2020.

在2019年，我们使用多线程进一步提高了性能，该多线程将模拟分为由连接的模拟零件岛组成的工作。 我们仍然存在与LDL相关的性能问题，我们最终在2020年初解决了该问题。

The physics engine is still being improved and optimized for performance, and we plan on adding new features for the foreseeable future.

物理引擎仍在改进和优化性能，我们计划在可预见的将来添加新功能。

## 实现物理定律 (Implementing the Laws of Physics)  
The main objective of a physics engine is to simulate the motion of bodies in a virtual environment. In our physics engine, we care about bodies that are rigid, that collide and have constraints with each other.

物理引擎的主要目标是模拟虚拟环境中物体的运动。 在我们的物理引擎中，我们关心的是刚体，碰撞和相互约束的物体。

A physics engine is organized into two phases: collision detection and solving. Collision detection finds intersections between geometries associated with the rigid bodies, generating appropriate collision information such as collision points, normals and penetration depths. Then a solver updates the motion of rigid bodies under the influence of the collisions that were detected and constraints that were provided by the user.

物理引擎分为两个阶段：碰撞检测和求解。 碰撞检测计算与刚体关联的几何形状之间的相交点，从而生成适当的碰撞信息，例如碰撞点，法线和穿透深度。 然后， 求解器在检测到的碰撞和用户提供的约束的影响下更新刚体的运动。

The motion is the result of the solver interpreting the laws of physics, such as conservation of energy and momentum. But doing this 100% accurately is prohibitively expensive, and the trick to simulating it in real-time is to approximate to increase performance, as long as the result is physically realistic. As long as the basic laws of motion are maintained within a reasonable tolerance, this tradeoff is completely acceptable for a computer game simulation.

该运动是求解器解释物理定律(例如能量和动量守恒)的结果。 但是，100％准确地计算此结果的代价过高，而且只要结果在物理上是真实的，就可以实时模拟它，以提高性能。 只要基本运动规律保持在合理的公差范围内，这种折衷对于计算机游戏模拟是完全可以接受的。

## 迈出小步 (Taking Small Steps)  
The main idea of the physics engine is to discretize the motion using time-stepping. The equations of motion of constrained and unconstrained rigid bodies are very difficult to integrate directly and accurately. The discretization subdivides the motion into small time increments, where the equations are simplified and linearized making it possible to solve them approximately. This means that during each time step the motion of the relevant parts of rigid bodies that are involved in a constraint is linearly approximated.

物理引擎的主要思想是使用时间步长离散化运动。 受约束和不受约束的刚体的运动方程很难直接且准确地积分。 离散化将运动细分为较小的时间增量，其中方程式得以简化和线性化，从而可以近似地求解。 这意味着在每个时间步长中，约束中所涉及的刚体相关部分的运动都是线性近似的。

Although a linearized problem is easier to solve, it produces drift in a simulation containing non-linear behaviors, like rotational motion. Later we’ll see mitigation methods that help reduce the drift and make the simulation more plausible.

尽管线性化问题更容易求解，但在包含非线性行为(如旋转运动)的模拟中会产生漂移。 稍后，我们将看到缓解方法，这些方法可帮助减少漂移并使仿真更合理。

## 解决 (Solving)
Having linearized the equations of motion for a time step, we end up needing to solve a linear system or linear complementarity problem (LCP). These systems can be arbitrarily large and can still be quite expensive to solve exactly. Again the trick is to find an approximate solution using a faster method. A modern method to approximately solve an LCP with good convergence properties is the Projected Gauss-Seidel (PGS). It is an iterative method, meaning that with each iteration the approximate solution is brought closer to the true solution, and its final accuracy depends on the number of iterations.

将运动方程线性化一个时间步后，我们最终需要求解线性系统或线性互补问题 (LCP)。 这些系统可能很大，要精确求解仍然很昂贵。 再次，诀窍是使用更快的方法找到近似的解。 近似求解具有良好收敛性的LCP的现代方法是Projected Gauss-Seidel(PGS)。 这是一种迭代方法 ，这意味着每次迭代都会使近似解更接近真实解，并且其最终精度取决于迭代次数。

This animation shows how a PGS solver changes the positions of the bodies at each step of the iteration process, the objective being to find the positions that respect the ball and socket constraints while preserving the center of mass at each step (this is a type of positional solver used by the IK dragger). Although this example has a simple analytical solution, it’s a good demonstration of the idea behind the PGS. At each step, the solver fixes one of the constraints and lets the other be violated. After a few iterations, the bodies are very close to their correct positions. A characteristic of this method is how some rigid bodies seem to vibrate around their final position, especially when coupling interactions with heavier bodies. If we don’t do enough iterations, the yellow part might be left in a visibly invalid state where one of its two constraints is dramatically violated. This is called the high mass ratio problem, and it has been the bane of physics engines as it causes instabilities and explosions. If we do too many iterations, the solver becomes too slow, if we don’t it becomes unstable. Balancing the two sides has been a painful and long process.

该动画显示了PGS求解器如何在迭代过程的每个步骤中更新物体的位置，目的是找到在保留每个步骤的质心的同时尊重球窝约束的位置(这是一种IK拖动器使用的位置求解器)。 尽管此示例具有简单的分析解，但它很好地展示了PGS背后的思想。 在每个步骤中，求解器都会修下其中一个约束，并让另一个约束被违反。 经过几次迭代后，物体非常接近其正确位置。 这种方法的一个特点是某些刚体似乎在其最终位置周围振动，尤其是在与较重的物体耦合相互作用时。 如果我们没有进行足够的迭代，则黄色部分可能会处于明显无效的状态，在该状态下，其两个约束之一被严重违反。 这就是所谓的**高质量比问题**，它一直是物理引擎的祸根，因为它会引起不稳定和爆炸。 如果我们进行过多的迭代，则求解器将变得太慢，否则将变得不稳定。 双方保持平衡是一个痛苦而漫长的过程。

## 缓解策略 (Mitigation Strategies)  
A solver has two major sources of inaccuracies: time-stepping and iterative solving (there is also floating point drift but it’s minor compared to the first two). These inaccuracies introduce errors in the simulation causing it to drift from the correct path. Some of this drift is tolerable like slightly different velocities or energy loss, but some are not like instabilities, large energy gains or dislocated constraints.

求解器有两个主要的不准确性来源：时间步长和迭代求解(也有浮点漂移，但与前两个相比不大)。 这些不准确性会在仿真中引入错误，从而导致仿真偏离正确的路径。 这种漂移中的一些是可以忍受的，例如速度或能量损失略有不同，但有些则不，像不稳定，大量的能量获取或错位的约束。

Therefore a lot of the complexity in the solver comes from the implementation of methods to minimize the impact of computational inaccuracies. Our final implementation uses some traditional and some novel mitigation strategies:

因此，求解器中的许多复杂性来自实现方案，这些方案可最大程度地减少计算不精确的影响。 我们的最终实现使用一些传统的和新颖的缓解策略：

1. Warm starting: starting with the solution from a previous time-step to increase the convergence rate of the iterative solver

热启动：从上一个时间步开始求解，以提高迭代求解器的收敛速度

2. Post-stabilization: reprojecting the system back to the constraint manifold to prevent constraint drift

后稳定化：将系统重新投影回约束流形，以防止约束漂移

3. Regularization: adding compliance to the constraints ensuring a solution exists and is unique

正则化 ：增加对约束的合规性，以确保解决方案的存在和独特性

4. Pre-conditioning: using an exact solution to a linear subsystem, improving the stability of complex mechanisms

预处理：对线性子系统使用精确的解决方案，提高复杂机构的稳定性

Strategies 1, 2 and 3 are pretty traditional, but 3 has been improved and perfected by us. Also, although 4 is not unheard of, we haven’t seen any practical implementation of it. We use an original factorization method for large sparse constraint matrices and a new efficient way of combining it with the PGS. The resulting implementation is only slightly slower compared to pure PGS but ensures that the linear system coming from equality constraints is solved exactly. Consequently, the equality constraints suffer only from drift coming from the time discretization. Details on our methods are contained in my GDC 2020 presentation. Currently, we are investigating direct methods applied to inequality constraints and collisions.

策略1、2和3相当传统，但我们已经改进和完善了策略3。 同样，尽管4并非闻所未闻，但我们尚未看到它的任何实际实现。 对于大型稀疏约束矩阵，我们使用原始的分解方法，并将其与PGS组合的新有效方法。 与纯PGS相比，最终的实现仅稍慢一些，但可以确保精确求解来自等式约束的线性系统。 因此，等式约束仅受时间离散化的影响。 有关我们方法的详细信息包含在我的GDC 2020演示文稿中。 当前，我们正在研究应用于不平等约束和冲突的直接方法。

## 获取更多详细信息 (Getting More Details)   
Traditionally there are two mathematical models for articulated mechanisms: there are reduced coordinate methods spearheaded by Featherstone, that parametrize the degrees of freedom at each joint, and there are full coordinate methods that use a Lagrangian formulation.

传统上，存在两种用于铰接机构的数学模型：由Featherstone带头的简化坐标方法，可以参数化每个关节的自由度，还有使用拉格朗日公式的完全坐标方法。

We use the second formulation as it is less restrictive and requires much simpler mathematics and implementation.

我们使用第二种公式，因为它的限制较少，并且需要更简单的数学和实现方法。

The Roblox engine uses analytical methods to compute the dynamic response of constraints, as opposed to penalty methods that were used before. Analytics methods were initially introduced in Baraff 1989, where they are used to treat both equality and non-equality constraints in a consistent manner. Baraff observed that the contact model can be formulated using quadratic programming, and he provided a heuristic solution method (which is not the method we use in our solver).

与以前使用的惩罚方法相反，Roblox引擎使用分析方法来计算约束的动态响应。 分析方法最初是在Baraff 1989年引入的，用于以一致的方式处理平等和非平等约束。 Baraff观察到可以使用二次编程来建立接触模型，并且他提供了一种启发式求解方法(这不是我们在求解器中使用的方法)。

Instead of using force-based formulation, we use an impulse-based formulation in velocity space, originally introduced by Mirtich-Canny 1995 and further improved by Stewart-Trinkle 1996, which unifies the treatment of different contact types and guarantees the existence of a solution for contacts with friction. At each timestep, the constraints and collisions are maintained by applying instantaneous changes in velocities due to constraint impulses. An excellent explanation of why impulse-based simulation is superior is contained in the GDC presentation of Catto 2014.

我们不是使用基于力的公式，而是使用速度空间中基于脉冲的公式，该公式最初是由Mirtich-Canny 1995提出 ，并由Stewart-Trinkle 1996进一步改进，它统一了对不同接触类型的处理并保证了解决方案的存在。用于摩擦接触。 在每个时间步，通过应用由于约束脉冲而引起的瞬时速度变化来保持约束和碰撞。 Catto 2014的GDC演示中很好地解释了为什么基于脉冲的仿真更优越。

The frictionless contacts are modeled using a linear complementarity problem (LCP) as described in Baraff 1994. Friction is added as a non-linear projection onto the friction cone, interleaved with the iterations of the Projected Gauss-Seidel.

如Baraff 1994中所述，使用线性互补问题(LCP)对无摩擦接触进行建模。 摩擦作为非线性投影添加到摩擦锥上，并与Projected Gauss-Seidel的迭代交错。

The numerical drift that introduces positional errors in the constraints is resolved using a post-stabilization technique using pseudo-velocities introduced by Cline-Pai 2003. It involves solving a second LCP in the position space, which projects the system back to the constraint manifold.

通过使用Cline-Pai 2003引入的伪速度的后稳定化技术解决了在约束中引入位置误差的数值漂移。 它涉及求解位置空间中的第二个LCP，从而将系统投影回约束流形。

The LCPs are solved using a PGS / Impulse Solver popularized by Catto 2005 (also see Catto 2009). This method is iterative and considers each individual constraints in sequence and resolves it independently. Over many iterations, and in ideal conditions, the system converges to a global solution.

LCP使用Catto 2005普及的PGS / 脉冲求解器解决(另请参见Catto 2009 )。 此方法是迭代的，并按顺序考虑每个单独的约束并独立解决。 经过多次迭代，并在理想条件下，系统收敛到全局解决方案。

Additionally, high mass ratio issues in equality constraints are ironed out by preconditioning the PGS using the sparse LDL decomposition of the constraint matrix of equality constraints. Dense submatrices of the constraint matrix are sparsified using a method we call Body Splitting. This is similar to the LDL decomposition used in Baraff 1996, but allows more general mechanical systems, and solves the system in constraint space. For more information, you can see my GDC 2020 presentation.

另外，通过使用等式约束的约束矩阵的稀疏LDL分解对PGS进行预处理，可以消除等式约束中的高质量比率问题。 约束矩阵的密集子矩阵使用一种称为“身体分裂”的方法进行稀疏处理。 这类似于Baraff 1996中使用的LDL分解，但是允许使用更通用的机械系统，并在约束空间中求解该系统。 有关更多信息，请参阅我的GDC 2020演示文稿 。

The architecture of our solver follows the idea of Guendelman-Bridson-Fedkiw, where the velocity and position stepping are separated by the constraint resolution. Our time sequencing is:

我们的求解器的体系结构遵循Guendelman-Bridson-Fedkiw的思想 ，其中速度和位置步进由约束分辨率分开。 我们的时间顺序是：

1. Advance velocities
前进速度
2. Constraint resolution in velocity space and position space
速度空间和位置空间中的约束分辨率
3. Advance positions
前进位置

This scheme has the advantage of integrating only valid velocities, and limiting latency in external force application but allowing a small amount of perceived constraint violation due to numerical drift.

该方案的优点是仅积分有效速度，并限制了外力施加中的等待时间，但是由于数值漂移而允许少量感知到的约束冲突。

An excellent reference for rigid body simulation is the book Erleben 2005 that was recently made freely available. You can find online lectures about physics-based animation, a blog by Nilson Souto on building a physics engine, a very good GDC presentation by Erin Catto on modern solver methods, and forums like the Bullet Physics Forum and GameDev which are excellent places to ask questions.

刚出版的《 Erleben 2005 》一书是刚体模拟的绝佳参考，该书最近免费提供。 您可以找到有关基于物理的动画的在线讲座 ， 尼尔森·索托 ( Nilson Souto)的有关构建物理引擎的博客，埃林·卡托(Erin Catto)关于现代求解器方法的非常出色的GDC 演示 ，以及类似Bullet Physics Forum和GameDev的 论坛问题。

## 结论 (In Conclusion)  
The field of game physics simulation presents many interesting problems that are both exciting and challenging. There are opportunities to learn a substantial amount of cool mathematics and, physics and to use modern optimizations techniques. It’s an area of game development that tightly marries mathematics, physics and software engineering.

游戏物理模拟领域提出了许多令人兴奋且充满挑战的有趣问题。 有机会学习大量的很棒的数学和物理学，并使用现代的优化技术。 这个游戏开发领域紧密结合了数学，物理学和软件工程。

Even if Roblox has a good rigid body physics engine, there are areas where it can be improved and optimized. Also, we are working on exciting new projects like fracturing, deformation, softbody, cloth, aerodynamics and water simulation.

即使Roblox具有良好的刚体物理引擎，在某些方面仍可以改进和优化。 此外，我们正在致力于令人兴奋的新项目，例如压裂，变形，软体，布料，空气动力学和水模拟。

Maciej Mizerski is a Technical Director at Roblox that specializes in mathematical simulation and optimization. With more than 10 years in the games industry and a doctorate in mathematics, he holds a deep understanding of mathematical methods, physics simulation, optimization and cross platform development. Previously at Relic Entertainment and Radical Entertainment.

Maciej Mizerski是Roblox的技术总监，专门从事数学模拟和优化。 他在游戏行业拥有超过10年的经验，并获得了数学博士学位，他对数学方法，物理模拟，优化和跨平台开发有着深刻的理解。 以前在Relic Entertainment和Radical Entertainment工作。

Neither Roblox Corporation nor this blog endorses or supports any company or service. Also, no guarantees or promises are made regarding the accuracy, reliability or completeness of the information contained in this blog.

Roblox Corporation或本博客均不认可或支持任何公司或服务。 此外，对于本博客中包含的信息的准确性，可靠性或完整性，不做任何保证或承诺。
---
layout: default
---

# Project - 3D Reconstruction

Here is a little introduction about one of my previous projects -- 3D reconstruction.

## Basic Data Flow

<script src="mermaid.full.min.js"></script>

<div class="mermaid">
st=>start: Start
opInput=>operation: Input images/vedio
opDetect=>operation: Feature detect and match
opCompute=>operation: Compute params of camera
opFace=>operation: Reconstruct mesh model
opFix=>operation: Fix model using DB
e=>end
st->opInput->opDetect->opCompute->opFace->opFix->e
</div>
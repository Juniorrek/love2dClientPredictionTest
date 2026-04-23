TODO
- Separate input sequence from simulation tick. Replay on tick not input sequence???
- Separate simulation tick
    - Simulation tick
    - Input send rate
    - Snapshot send rate
    - Render rate
- Fixed DT back
- Interpolation

LATER
- Separate responsibilities better. PlayerLogic shouldn't handle rendering...
- If needed, for smoothness on rendering, interpolate between previous and current predicted state (if render FPS doesn’t line up exactly with 60 Hz / TEST)
- Simulate lag for better tests
- Input batching?
based on nmaggioni/r710-fan-controller script.

Only difference is CPU temps are removed so it doesn't require lm-sensors to work.
LM-SENSORS do not work in virtual environment so this script will work well with ESXi , Virtual Box, Hyper-V as long as you enable IPMI in IDRAC.
 Temperature check interval set to 15sec. 

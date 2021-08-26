<h1>based on nmaggioni/r710-fan-controller script.</h1>

Only difference is CPU temps are removed so it doesn't require lm-sensors to work.
LM-SENSORS do not work in virtual environment so this <b>script will work well with ESXi , Virtual Box, Hyper-V</b> as long as you enable IPMI in IDRAC.
 Temperature check interval set to 15sec. 
 
 
 
 
<h3>If you want to run it in the background as a service follow those steps:</h3>
 
<h4>1. edit r170fancontroller.service file and add your details</h4>
<h4>2. copy file to /etc/systemd/system/</h4> 
    sudo cp r170fancontroller.service /etc/systemd/system/

<h4> 3. reload system control</h4>
     sudo systemctl daemon-reload
<h4> 4. Start the service with:</h4>
     sudo systemctl start r170fancontroller.service
    <br> sudo systemctl enable r170fancontroller.service
     
 <h4>Thats all! Now you have fan controll in your VM running as a service. You can check status by typing:</h4> 
     systemctl status r170fancontroller.service

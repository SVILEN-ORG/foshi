FoShi is a small script that monitors every X seconds a Foscam C1 camera by utilizing camera's integrated PIR and sound sensors. This offloads the Shinobi server CPU from having to deal with the motion detection alarm triggering, which is also sometimes trickier to configure than the integrated camera PIR/sound sensors. The sensitivity of each camera sensor can be configured via the C1 camera web interface.

Requirements:
- works out-of-the-box (tested) on a FreeNAS 11.x jail with the default jail shell - csh ; could be easily rewritten to other shells, keepin the same logic.
- curl installed within the jail (run from the FreeNAS host: iocage pkg install <jailname> curl)

Preparation:
1. Copy the files to a folder somewhere, for example: /usr/local/share/foshi
3. Change the working directory to the chosen one:
cd /usr/local/share/foshi
4. Create a configuration file for each camera using the provided template camera_example.cfg.example ; each config file must end on .cfg; Example:
cp camera_example.cfg.example camera1.cfg
nano camera1.cfg
5. Make foshi.csh and single_foshi.csh executable:
chmod +x *.csh

Running the main script:
- for a single camera run:
./foshi.csh start camera.cfg

- for all cameras having a cfg file run:
./foshi.csh start all

Checking the script: in the jail console, type:
ps | grep single_foshi

The result should be something like:
31767  0- SJ   1:40.29 /bin/csh ./single_foshi.csh camera1.cfg

Stopping the script:
./foshi.csh stop camera.cfg
or
./foshi.csh stop all

Restarting the script:
./foshi.csh restart camera.cfg
or
./foshi.csh restart all

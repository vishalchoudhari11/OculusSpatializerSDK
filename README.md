# Spatializer SDK

This repository is built on top of Oculus Audio SDK and has been developed to generate audio files that mimic time-varying moving sound sources. Inputs are a set of N monaural sound files, each with its own specific trajectory. 

NOTE: The only reference for devloping the processing_sound.cpp script was found at the end of the file: AudioSDK/Include/OVR_Audio.h

## Installation

Download/clone the repository in your local computer. The workflow is as follows:

1. Create a new folder under the "Sound Samples" directory and place the set of N monaural sound files in this.
2. Open "preprocessing_sound.m" file on MATLAB and perform appropriate parameter adjustment.
3. Run the MATLAB script. It should generate files in the "ToCPP" folder.
4. Ensure that your current directory is the root of the repository. Run the following command in the terminal to apply spatialisation to the sound files and generate a single file:
```bash
g++ processing_sound.cpp -IAudioSDK/Include -LAudioSDK/Lib/Linux64 -lovraudio64.
```
Note that you might have to add/link a library to OS's library list if the above command throws an error.

5. New files should be written to "FromCPP" directory.
6. Open the MATLAB script "post-recessing_sound.m", make appropriate parameter adjustments and execute the file.
7. The final output file having spatialised the passed sounds is available under "Spatialized" directory. 

## Conclusion

Comments/ideas for building more general features are welcome. 

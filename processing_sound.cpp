#include <iostream>
#include "OVR_Audio.h"
using namespace std;


int main(){
	cout << "My neighbours are noisy!" << endl;

    int major, minor, patch;
    const char *VERSION_STRING;

    VERSION_STRING = ovrAudio_GetVersion( &major, &minor, &patch );
    printf( "Using OVRAudio: %s\n", VERSION_STRING );
    
    
    
    
    ovrAudioContext context;
    ovrAudioEnable room_setting_SRM = ovrAudioEnable_SimpleRoomModeling;
    ovrAudioEnable room_setting_LR  = ovrAudioEnable_LateReverberation;
    ovrAudioEnable room_setting_RR  = ovrAudioEnable_RandomizeReverb;
    
    
    
    ovrAudioContextConfiguration config = {};
    
    config.acc_Size = sizeof( config );
    config.acc_SampleRate = 48000;
    config.acc_BufferLength = 512;
    config.acc_MaxNumSources = 16;
    
    

    cout << "My neighbours are noisy again!" << endl;
   	return 0;

}

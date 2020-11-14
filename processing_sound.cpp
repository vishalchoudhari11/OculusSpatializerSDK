#include <iostream>
#include "OVR_Audio.h"
using namespace std;

void setup()
{
    // Version checking is not strictly necessary but it's a good idea!
    int major, minor, patch;
    const char *VERSION_STRING;

    VERSION_STRING = ovrAudio_GetVersion( &major, &minor, &patch );
    printf( "Using OVRAudio: %s\n", VERSION_STRING );

    if ( major != OVR_AUDIO_MAJOR_VERSION ||
         minor != OVR_AUDIO_MINOR_VERSION )
    {
      printf( "Mismatched Audio SDK version!\n" );
    }

    ovrAudioContextConfiguration config = {};

    config.acc_Size = sizeof( config );
    config.acc_SampleRate = 48000;
    config.acc_BufferLength = 512;
    config.acc_MaxNumSources = 16;

    ovrAudioContext context;

    if ( ovrAudio_CreateContext( &context, &config ) != ovrSuccess )
    {
      printf( "WARNING: Could not create context!\n" );
      return;
    }
    
//    ovrAudio_DestroyContext(context);
    
}

int main(){
	cout << "My neighbours are noisy!" << endl;
    
    setup();
    
    ovrAudioContext c1;
    
    ovrAudioEnable room_setting_SRM = ovrAudioEnable_SimpleRoomModeling;
    ovrAudioEnable room_setting_LR  = ovrAudioEnable_LateReverberation;
    ovrAudioEnable room_setting_RR  = ovrAudioEnable_RandomizeReverb;
    
    ovrAudioContextConfiguration config = {};
    
    config.acc_Size = sizeof( config );
    config.acc_SampleRate = 48000;
    config.acc_BufferLength = 512;
    config.acc_MaxNumSources = 16;
    
    result = ovrAudio_CreateContext(&c1, &config);
    if (result == 1){
        cout << "Context has been created successfully!" << endl;
    } else{
        cout << "Oops! Context could not be created." << endl;
    }

//    ovrAudio_DestroyContext(c1);
//    ovrAudio_Shutdown();
    
    cout << "My neighbours are noisy again!" << endl;
   	return 0;

}

#include <iostream>
#include "OVR_Audio.h"
using namespace std;


int main(){
	cout << "My neighbours are noisy!" << endl;
    
    ovrAudioContext context;
    
    ovrAudioEnable room_setting_SRM = ovrAudioEnable_SimpleRoomModeling;
    ovrAudioEnable room_setting_LR  = ovrAudioEnable_LateReverberation;
    ovrAudioEnable room_setting_RR  = ovrAudioEnable_RandomizeReverb;
    
    ovrAudioContextConfiguration config = {};
    
    config.acc_Size = sizeof( config );
    config.acc_SampleRate = 48000;
    config.acc_BufferLength = 512;
    config.acc_MaxNumSources = 16;

    shutdownOvrAudio(context);
    
    cout << "My neighbours are noisy again!" << endl;
   	return 0;

}


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
    
    shutdownOvrAudio(context);
    
}

void shutdownOvrAudio(ovrAudioContext c)
{
   ovrAudio_DestroyContext(c);
   ovrAudio_Shutdown();
}

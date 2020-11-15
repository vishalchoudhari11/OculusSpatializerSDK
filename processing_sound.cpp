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
//  Check setup
    setup();
    
//  Declaring a context
    ovrAudioContext c1;
    
//  Room setting parameters
    ovrAudioEnable room_setting_SRM = ovrAudioEnable_SimpleRoomModeling;
    ovrAudioEnable room_setting_LR  = ovrAudioEnable_LateReverberation;
    ovrAudioEnable room_setting_RR  = ovrAudioEnable_RandomizeReverb;

//  Configuring AudioContext Parameters
    ovrAudioContextConfiguration config = {};
    
    config.acc_Size = sizeof( config );
    config.acc_SampleRate = 44100;
    config.acc_BufferLength = 512;
    config.acc_MaxNumSources = 16;
    
//  Creating a context with mentioned configuration and checking for success.
    int result = ovrAudio_CreateContext(&c1, &config);
    if (result == 0){
        cout << "Context has been created successfully!" << endl;
    } else{
        cout << "Oops! Context could not be created." << endl;
    }
    
//  Passing previous room setting options to the created context and checking
    
    int rs1 = ovrAudio_Enable(c1, room_setting_SRM, 1);
    int rs2 = ovrAudio_Enable(c1, room_setting_LR, 1);
    int rs3 = ovrAudio_Enable(c1, room_setting_RR, 1);
    
    if( (rs1 == ovrSuccess) && (rs2 == ovrSuccess) && (rs3 == ovrSuccess)  ){
        cout<<"Room setting options have been set!" << endl;
    } else{
        cout << "Oops! Room setting parameters have not been set." << endl;
    }

//  Setting simple room parameters, passing to the context and checking
    
    ovrAudioBoxRoomParameters brp = {};

    brp.brp_Size = sizeof( brp );
    brp.brp_ReflectLeft = brp.brp_ReflectRight = 0.4;
    brp.brp_ReflectUp = brp.brp_ReflectDown = 0.4;
    brp.brp_ReflectFront = brp.brp_ReflectBehind = 0.4;

    brp.brp_Width = 20;
    brp.brp_Height = 5;
    brp.brp_Depth = 20;

    int brp1 = ovrAudio_SetSimpleBoxRoomParameters(c1, &brp );
    
    if( brp1 == ovrSuccess ){
        cout<<"Box room params have been set!" << endl;
    } else{
        cout << "Oops! Box room params have not been set." << endl;
    }
    
    
    
    
//    ovrAudio_DestroyContext(c1);
//    ovrAudio_Shutdown();
    
    cout << "My neighbours are noisy again!" << endl;
   	return 0;

}

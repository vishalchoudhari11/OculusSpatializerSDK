#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <sstream>
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
//    ovrAudioEnable room_setting_LR  = ovrAudioEnable_LateReverberation;
//    ovrAudioEnable room_setting_RR  = ovrAudioEnable_RandomizeReverb;

//  Configuring AudioContext Parameters
    ovrAudioContextConfiguration config = {};
    
    config.acc_Size = sizeof( config );
    config.acc_SampleRate = 16000;
//    config.acc_SampleRate = 44100;
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
    
    int rs1 = ovrAudio_Enable(c1, ovrAudioEnable_SimpleRoomModeling, 1);
//    int rs2 = ovrAudio_Enable(c1, room_setting_LR, 1);
//    int rs3 = ovrAudio_Enable(c1, room_setting_RR, 1);
    

    if((rs1 == ovrSuccess)){
//    if( (rs1 == ovrSuccess) && (rs2 == ovrSuccess) && (rs3 == ovrSuccess)  ){
        cout<<"Room setting options have been set!" << endl;
    } else{
        cout << "Oops! Room setting parameters have not been set." << endl;
    }
    
    int rsN = ovrAudio_SetReflectionModel(c1, ovrAudioReflectionModel_StaticShoeBox);

//  Setting simple room parameters, passing to the context and checking
    
    ovrAudioBoxRoomParameters brp = {};

    brp.brp_Size = sizeof( brp );
    brp.brp_ReflectLeft = brp.brp_ReflectRight = 0.97;
    brp.brp_ReflectUp = brp.brp_ReflectDown = 0.97;
    brp.brp_ReflectFront = brp.brp_ReflectBehind = 0.97;

    brp.brp_Width = 25;
    brp.brp_Height = 5;
    brp.brp_Depth = 20;

    int brp1 = ovrAudio_SetSimpleBoxRoomParameters(c1, &brp );
    
    if( brp1 == ovrSuccess ){
        cout<<"Box room params have been set!" << endl;
    } else{
        cout << "Oops! Box room params have not been set." << endl;
    }
    
//    int rsN2 = ovrAudio_SetReflectionModel(c1, ovrAudioReflectionModel_StaticShoeBox);
    
    ovrAudio_SetSharedReverbWetLevel(c1, 0.5);
    
//  Managing sounds
    
    
//    int N = 2;
//    char sound[N][20] = {"Host_44100.csv", "Male1_44100.csv"};
//    char posns[N][20] = {"Host_xyz.csv", "Male1_xyz.csv"};
    
    int N = 1;
    char sound[N][20] = {"male_16000.csv"};
    char posns[N][20] = {"male_xyz.csv"};

    //  Open sound and posn CSV files
    
    ifstream sound_files[N];
    ifstream posns_files[N];
    
    for (int i = 0; i < N; i++){
        
        sound_files[i].open(sound[i]);
        posns_files[i].open(posns[i]);
        
    }
    
    //  Opening an output file
    
    ofstream opfile;
    opfile.open("output_male_0.97_20_5_20_3.csv");
    

    
//  Declaring variables
    
    string posn_string;
    int proceed = 1;
    int buffer_size = 512;
    int records1 = 0;
    int records2 = 0;
    
//  Determine how many blocks and set HINTs
    
    int blocks[N];
    
    for (int i = 0; i < N; i ++){
        
//      Set hints
        ovrAudio_SetAudioSourceFlags( c1, i, ovrAudioSourceFlag_WideBand_HINT);
        
        int blk_count  = 0;
        while(posns_files[i].good()){
            getline(posns_files[i], posn_string, '\n');
            blk_count  = blk_count + 1;
        }
        
        cout<<"File: "<<i<<" has "<<blk_count<<" blocks"<<endl;
        blocks[i]  = blk_count;
    }
    
//  Close and re-open posn files for further processing
    
    for(int i = 0; i < N; i++)
    {
        posns_files[i].close();
        posns_files[i].open(posns[i]);
    }
    
// Finding the least
    
    int least = blocks[0];
    
    for(int i = 0; i < N; i++){
        if (blocks[i] <= least){
            least = blocks[i];
        }
    }
    
    cout<<"Least number of blocks: "<<least<<endl;
    
    
//  Applying spatialisation
    
    for(int blk = 1; blk <= least - 2; blk++){
    
        cout<<"Processing block "<<blk<<" of "<<least-2<<"."<<endl;
        
//      Read and apply block position
        
        for(int i = 0; i < N; i++){


            vector<string> v;

            getline(posns_files[i], posn_string, '\n');

//          Parsing

            stringstream ss(posn_string);

            while (ss.good()) {
                string substr;
                getline(ss, substr, ',');
                v.push_back(substr);
            }

            float x, y, z;

            x = stof(v[0]);
            y = stof(v[1]);
            z = stof(v[2]);

            cout<<"Sound No: "<<i<<" Posn: "<<endl<<x<<endl<<y<<endl<<z<<endl;
            ovrAudio_SetAudioSourcePos(c1, i, x, y, z);

        }
        
        
//      Read blocks
        
        uint32_t Flags = 0, Status = 0;
        
        float inbuffer[512];
        float outbuffer[1024];
        float mixbuffer[1024];
        string sample_string;
        
        for(int i = 0; i < N; i++){
        
            for(int sample_no = 0; sample_no < 512; sample_no++){
                getline(sound_files[i], sample_string, '\n');
                inbuffer[sample_no] = stof(sample_string);
            }
            
            ovrAudio_SpatializeMonoSourceInterleaved(c1, i, &Status, outbuffer, inbuffer);
            
            for(int j = 0; j < 1024; j ++){
                if (i==0){
                    mixbuffer[j] = outbuffer[j];
                } else {
                    mixbuffer[j] = mixbuffer[j] + outbuffer[j];
                }
            }
            
        }
        
        
        
        
        
        
//      Write output files
        
        for(int j = 0; j < 1024; j++){
            opfile<<mixbuffer[j]<<endl;
        }
    }

    
    
    
    
    
    
    
    
    
//    do{
//
////        Reading block-by-block [buffer_size values]
////        Location changes once per buffer_block
//
////        Setting position of sources
//

//
//        records1 = records1 + 1;
//        cout<<"Records1 count: "<<records1<<endl;
//
////      If either posn files is at end, set fetch_block = 0
//        int check = 0;
//
//        for(int i = 0; i < N; i++){
//            check = check + posns_files[i].good();
//        }
//
//        if (check != N){
//            proceed = 0;
//            cout<<"Ending, proceed = 0. Records1 counted: "<<records1<<endl;
//        }
//
//
////      Fetching block
//
//        if (proceed == 1){
//
//            records2 = records2 + 1;
//
//        }
//
//
//
////      Apply spatialisation to the block
//
//    }
//    while(proceed == 1);
    
//    cout<<"Value of records2: "<<records2<<endl;
    
//  CSV Write
    
    
    
    
//    ovrAudio_DestroyContext(c1);
//    ovrAudio_Shutdown();
    
//  Closing the files
    
    for (int i = 0; i < N; i++){
        
        sound_files[i].close();
        posns_files[i].close();
        
    }
    
    opfile.close();
    
    cout << "My neighbours are noisy again!" << endl;
   	return 0;

}

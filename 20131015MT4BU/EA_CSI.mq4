//+------------------------------------------------------------------+
//|                                                       EA_CSI.mq4 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

extern int    tf = PERIOD_H1; //time frame 

extern string s1 = "EURJPYm";
extern string s2 = "EURUSDm";
extern string s3 = "AUDCADm";
extern string s4 = "AUDCHFm";
extern string s5 = "AUDJPYm";
extern string s6 = "AUDNZDm";
extern string s7 = "AUDUSDm";
extern string s8 = "CADJPYm";
extern string s9 = "CHFJPYm";
extern string s10= "CHFJPYm";
extern string s11= "EURAUDm";
extern string s12= "EURCADm";
extern string s13= "EURCHFm";
extern string s14= "USDJPYm";
extern string s15= "USDCHFm";
extern string s16= "USDCADm";
extern string s17= "NZDUSDm";
extern string s18= "NZDJPYm";
extern string s19= "NZDCHFm";
extern string s20= "GBPUSDm";
extern string s21= "GBPNZDm";
extern string s22= "GBPJPYm";
extern string s23= "GBPCHFm";
extern string s24= "GBPCADm";
extern string s25= "GBPAUDm";
extern string s26= "EURNZDm";
extern string s27= "EURDKKm";
extern string s28= "EURGBPm";
              
static bool   initialRun = true;

double        csi[28], orderedCSI[28];

string        s[28], orderedSym[28];



int start()   {
   if(initialRun)   {//initially, copy symbol names into string array 
      s[0] = s1;
      s[1] = s2;
      s[2] = s3;
      s[3] = s4;
      s[4] = s5;
      s[5] = s6;
      s[6] = s7;
      s[7] = s8;
      s[8] = s9;
      s[9] = s10;
      s[10]= s11;
      s[11]= s12;
      s[12]= s13;
      s[13]= s14;
      s[14]= s15;
      s[15]= s16;
      s[16]= s17;
      s[17]= s18;
      s[18]= s19;
      s[19]= s20;
      s[20]= s21;
      s[21]= s22;
      s[22]= s23;
      s[23]= s24;
      s[24]= s25;
      s[25]= s26;
      s[26]= s27;
      s[27]= s28;
      
      for(int i=0; i<28; i++)   { //get csi value for each symbol
         double c = iCustom(s[i], tf, "A_i_WWJ_CSI", 0, 0);
         csi[i] = c;
      }//close for
      
      Print("max. CSI[",ArrayMaximum(csi),"] = ", csi[ArrayMaximum(csi)]," for ", s[ArrayMaximum(csi)] );
      
      for(i=0; i<28; i++)   { //order 
         int maxIndx = ArrayMaximum(csi);
         orderedCSI[i] = csi[maxIndx];
         orderedSym[i] = s[maxIndx];
         csi[maxIndx]  = 0.0;
      }
      
      for(i=0; i<28; i++)   { //output
         Print("orderedCSI[", i, "] = ", orderedCSI[i], "  for ", orderedSym[i]);
      }
         
      initialRun = false;
  
   }//close if(initialRun)
   
   return(0);
}


int init()  {
   //ArrayInitialize
   return(0);
}
  
  

int deinit()   {
   return(0);
}
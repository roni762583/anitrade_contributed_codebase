//+------------------------------------------------------------------+
//|                                 IBFX Autochartist MT4 Plugin.mq4 |
//|                                  Copyright © 2006-2009, IBFX.com |
//|                                              http://www.ibfx.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, InterbankFX.com"
#property link      "http://www.interbankfx.com"

#property indicator_chart_window
#property indicator_buffers 0
#include <stdlib.mqh>

//---- input parameters
extern string      Display_Options = "------------  Display Options  -----------";
extern  color          LABEL_COLOR = Gray;
extern  color          TITLE_COLOR = MediumSeaGreen;
extern  color           TEXT_COLOR = SteelBlue;
extern  color       CompletedColor = MidnightBlue;
extern  color        EmergingColor = Red;
extern   bool       DisplayFilters = True;
extern   bool DrawFromCurrentPrice = False;

extern string     Filter_Options = "------------  Filter Options   -----------";
extern double         minClarity = 0.0;
extern double        minBreakout = 0.0;
extern double      minUniformity = 0.0;
extern double    minInitialTrend = 0.0;
extern double  minOverallQuality = 0.0;
extern int             minLength = 0;
extern int    qtyCompleteToShowOnChart = 1;
extern int    qtyEmergingToShowOnChart = 1;
extern string     debugFilename = "";

// some defiitions
#define scSearchType_Symbols    3
#define scActive_True                   1
#define scActive_False                  0

#define STATE_NONE                          0
#define STATE_STARTUP                       1
#define STATE_INIT                          2
#define STATE_FETCHCONFIG                   3
#define STATE_FETCHPERMISSIONS              4
#define STATE_CONNECTED                     5
#define STATE_LOOP                          6
#define STATE_ERROR                          7
#define STATE_TERMINATED                     8

#define erINTERNALERROR                     -1
#define scSearchType_Symbols                3
#define scActive_True                       1
#define scActive_False                      0
#define erSUCCESS					              0
#define erSTRINGTRUNCATED				       -2001
#define erSEARCHOBJECTHASNORESULTS		    -2002
#define erINVALIDCHARTPATTERNSEARCH		    -2003
#define erINVALIDCHARTPATTERNRESULT	       -2004
#define erNOTINITIALIZED				       -2005
#define erINDEXOUTOFBOUNDS				       -2006
#define erITEMNOTFOUND					       -2007
#define erABORT                            -2008
#define erNOPERMISSIONS                    -2009
#define erUNKNOWNTIMEZONE                  -2010
#define erTIMECONVERSIONERROR              -2011
#define erINVALIDCHARTPATTERNIMAGE		    -2012
#define erBUFFERTRUNCATED                  -2013
#define erIMAGENOTDOWNLOADED               -2014
#define erIMAGECONVERSIONERROR             -2015
#define erINVALIDCHARTPATTERNDATA		    -2016
#define erWRONGSERVER                      -3001
#define erNOINTERNETCONNECTIONEXCEPTION    -1001
#define erDATACORRUPTEXCEPTION             -1002
#define erINVALIDVALUESPECIFIED            -1003
#define erVALUENOTSPECIFIEDEXCEPTION       -1004
#define erINTERNALEXCEPTION                -1005
#define erCOMMUNICATIONEXCEPTION           -1006
#define erSERVICENOTAVAILABLEEXCEPTION     -1007
#define erUKNOWNEXCEPTION                  -1008
#define erREQUESTTOOSOONEXCEPTION          -1009
#define erIMAGECONVERSIONEXCEPTION         -1010
#define erAUTHFROMDIFFERENTMACHINE         -1011
#define erINSUFFICIENTPERMISSIONS          -1012
#define erSAVINGIMAGEEXCEPTION             -1013
#define erSAVINGDATAEXCEPTION              -1015
#define erINVALIDRESULTEXCEPTION           -1014
#define erCONFIGNOTDOWNLOADEDEXCEPTION     -1016
#define erFORCEUPGRADEEXCEPTION            -1017
#define erIMAGENOTDOWNLOADEDEXCEPTION      -1018

//Authentication return values
#define atError   -1
#define atNone    0
#define atDemo    1
#define atLive    2
//interval of API connection checking (min)
#define CONNECTION_CHECK_INTERVAL   30

// global variables;
int State = STATE_NONE;
int SearchIndex = -1;
int connected = -1;
int old_qty = 0;
int new_qty = 0;
int error = 0;
int qtyComplete = 0;
int qtyEmerging = 0;
int hr = erSUCCESS;
int TimeShift = 255;
int LastConnectionCheck;

string Server = "interbankfx.autochartist.com";
string Config = "/Autochartist_INTERBANKFX.ini";
int BrokerID = 35;
string ProductName = "IBFX-PRS";
string Username = "012345689012345689012345689012345689012345689012345689012345689012345689012345689012345689";
string Password = "123456890123456890123456890123456890123456890123456890123456890123456890123456890123456890";
#define TIMESHIFT 2

double supBuf[],resBuf[];

// imports from the external dll
#import "stdcall_ChartPatterns.dll"
   void Message(string);   
   int ac_Initialize(string server, string username, string password,int brokerid, int userproxy,
            string proxyaddress, int proxyport,int proxyauth, string proxyusername,
            string proxypassword, int conntimeout, int datatimeout,int permissionscallbackwindowhandle, int permissionsmsg,
            int configcallbackwindowhandle, int configmsg, string debugFilename);
   int ac_FetchConfiguration(string configurl);
   int ac_GetErrorCode();
   int ac_GetLatestError(string buffer, int bufflen);
   int ac_FetchPermissions();
   int ac_GetDIRECTAuth(string username, string password, int brokerid);
   int ac_GetMTTAuth(string username, string password, int brid);
   int ac_GetMTTimeDiff(string server, int clienthour, int clientminute);
   int ac_GetUsernameFromRegistry(string username, int usernamebufflen);
   int ac_GetPasswordFromRegistry(string password, int passwordbuflen);
   int IsAutochartistConnected();
   
   int CPSearch_NewBlank(int fetchCallbackWindow, int fetchMsg, int updateCallbackWindow, int updateMsg, string directory);
   int CPSearch_NewLoad(int fetchCallbackWindow, int fetchMsg, int updateCallbackWindow, int updateMsg, string str, string directory);
   int CPSearch_NewForm(int fetchCallbackWindow, int fetchMsg, int updateCallbackWindow, int updateMsg, string defaultSearchName, string formTitle, string skinFilename, string directory);
   int CPSearch_EditForm(int SearchIndex, string formTitle, string skinFilename);
   int CPSearch_Fetch(int SearchIndex);
   int CPSearch_Update(int SearchIndex);
   int CPSearch_Delete(int SearchIndex);
   int CPSearch_GetErrorCode(int SearchIndex);
   int CPSearch_GetSaveString(int SearchIndex, string buffer, int bufflen);
   int CPSearch_SetSearchType(int SearchIndex, int searchType);
   int CPSearch_SetExchange(int SearchIndex, string exchange);
   int CPSearch_SetSymbols(int SearchIndex, string symbols);
   int CPSearch_SetGroupID(int SearchIndex, int groupID);
   int CPSearch_SetEmerging(int SearchIndex, int emerging);
   int CPSearch_SetInterval(int SearchIndex, int interval);
   int CPSearch_SetDirection(int SearchIndex, int direction);
   int CPSearch_SetTrendChange(int SearchIndex, int trendChange);
   int CPSearch_SetLength(int SearchIndex, int length);
   int CPSearch_SetPatternQuality(int SearchIndex, double patternQuality);
   int CPSearch_SetInitialTrend(int SearchIndex, double initialTrend);
   int CPSearch_SetUniformity(int SearchIndex, double uniformity);
   int CPSearch_SetClarity(int SearchIndex, double clarity);
   int CPSearch_SetBreakout(int SearchIndex, double breakout);
   int CPSearch_SetVolumeIncrease(int SearchIndex, double volumeIncrease);
   int CPSearch_SetPatterns(int SearchIndex, int patterns);
   int CPSearch_SetDaysBack(int SearchIndex, int daysBack);
   int CPSearch_SetTemporary(int SearchIndex, int temporary);
   int CPSearch_SetQtyRecords(int SearchIndex, int qtyRecords);
   int CPSearch_SetActive(int SearchIndex, int active);
   int CPSearch_SetDescription(int SearchIndex, string description);
   int CPSearch_GetSearchType(int SearchIndex);
   int CPSearch_GetExchange(int SearchIndex, string buffer, int bufflen);
   int CPSearch_GetSymbols(int SearchIndex, string buffer, int bufflen);
   int CPSearch_GetGroupID(int SearchIndex);
   int CPSearch_GetEmerging(int SearchIndex);
   int CPSearch_GetInterval(int SearchIndex);
   int CPSearch_GetDirection(int SearchIndex);
   int CPSearch_GetTrendChange(int SearchIndex);
   int CPSearch_GetLength(int SearchIndex);
   double CPSearch_GetPatternQuality(int SearchIndex);
   double CPSearch_GetInitialTrend(int SearchIndex);
   double CPSearch_GetUniformity(int SearchIndex);
   double CPSearch_GetClarity(int SearchIndex);
   double CPSearch_GetBreakout(int SearchIndex);
   double CPSearch_GetVolumeIncrease(int SearchIndex);
   int CPSearch_GetPatterns(int SearchIndex);
   int CPSearch_GetDaysBack(int SearchIndex);
   int CPSearch_GetTemporary(int SearchIndex);
   int CPSearch_GetQtyRecords(int SearchIndex);
   int CPSearch_GetActive(int SearchIndex);
   int CPSearch_GetDescription(int SearchIndex, string buffer, int bufflen);
   int CPResults_GetQtyResults(int searchSearchIndex);
   int CPResults_GetQtyNewComplete(int searchSearchIndex);
   int CPResults_GetQtyNewEmerging(int searchSearchIndex);
   int CPResults_ResetQtyResultsFound(int searchIndex);
   int CPResults_GetResultSearchIndex(int searchSearchIndex, int ResultUID);
   int CPResults_SortResults(int searchSearchIndex, int column, int direction);
   int CPResults_GetResultUID(int searchSearchIndex, int resultSearchIndex);
   int CPResults_GetSymbolID(int searchSearchIndex, int resultSearchIndex);
   int CPResults_GetSymbol(int searchSearchIndex, int resultSearchIndex, string buffer, int bufflen);
   int CPResults_GetExchange(int searchSearchIndex, int resultSearchIndex, string buffer, int bufflen);
   int CPResults_GetInterval(int searchSearchIndex, int resultSearchIndex);
   int CPResults_GetIntervalString(int searchSearchIndex, int resultSearchIndex, string buffer, int bufflen);
   int CPResults_GetPatternID(int searchSearchIndex, int resultSearchIndex);
   int CPResults_GetPatternName(int searchSearchIndex, int resultSearchIndex, string buffer, int bufflen);
   int CPResults_GetTrendChange(int searchSearchIndex, int resultSearchIndex, string buffer, int bufflen);
   int CPResults_GetPatternLengthBars(int searchSearchIndex, int resultSearchIndex);
   int CPResults_GetDirection(int searchSearchIndex, int resultSearchIndex);
   int CPResults_GetInitialTrend(int searchSearchIndex, int resultSearchIndex);
   int CPResults_GetVolumeIncrease(int searchSearchIndex, int resultSearchIndex);
   int CPResults_GetClarity(int searchSearchIndex, int resultSearchIndex);
   int CPResults_GetSymmetry(int searchSearchIndex, int resultSearchIndex);
   int CPResults_GetPatternQuality(int searchSearchIndex, int resultSearchIndex);
   double CPResults_GetPatternStartPrice(int searchSearchIndex, int resultSearchIndex);
   double CPResults_GetPatternEndPrice(int searchSearchIndex, int resultSearchIndex);
   double CPResults_GetResy0(int searchSearchIndex, int resultSearchIndex);
   double CPResults_GetResy1(int searchSearchIndex, int resultSearchIndex);
   double CPResults_GetSupporty0(int searchSearchIndex, int resultSearchIndex);
   double CPResults_GetSupporty1(int searchSearchIndex, int resultSearchIndex);
   double CPResults_GetPredPriceFrom(int searchSearchIndex, int resultSearchIndex);
   double CPResults_GetPredPriceTo(int searchSearchIndex, int resultSearchIndex);
   double CPResults_GetPredPercentFrom(int searchSearchIndex, int resultSearchIndex);
   double CPResults_GetPredPercentTo(int searchSearchIndex, int resultSearchIndex);
   int CPResults_GetTemporaryPattern(int searchSearchIndex, int resultSearchIndex);
   int CPResults_isEmerging(int searchSearchIndex, int resultSearchIndex);
   int CPResults_TimeLong2TimeString(int timesrc, string format, string buffer, int bufflen);
   datetime CPResults_GetStartTime(int searchIndex, int resultIndex);
   datetime CPResults_GetEndTime(int searchIndex, int resultIndex);
   datetime CPResults_TimeAsLong2GMT(int timesrc, string timezone);
   datetime CPResults_GetResx0(int searchIndex, int resultIndex);
   datetime CPResults_GetResx1(int searchIndex, int resultIndex);
   datetime CPResults_GetSupportx0(int searchIndex, int resultIndex);
   datetime CPResults_GetSupportx1(int searchIndex, int resultIndex);
   datetime CPResults_GetPredTimeFrom(int searchIndex, int resultIndex);
   datetime CPResults_GetPredTimeTo(int searchIndex, int resultIndex);
   int CPPermissions_SymbolExists(string symbol);
   int CPPermissions_IntervalExists(int interval);
   int CPPermissions_GetQtySymbols();

#import

//+------------------------------------------------------------------+
//| Global Vars                                                      |
//+------------------------------------------------------------------+
#define VERSION  3.10                                        //---- !DNC! MAIN CODE VERSION NUMBER 
//|++++++++++++++++++++++++++++++ Display Settings 
int    Window = 0;                                          //---- SELECT WINDOW FOR INDICATOR 0 = MainChart...
int    Corner = 1;                                          //---- SELECT CORNER FOR INDICATOR 1 = TopRight ...
int     Width = 200;                                        //---- WIDTH OF MAIN DISPLAY 
int    OffXet = 5;                                          //---- X-Axis OffSet
int    OffYet = 3;                                          //---- Y-Axis OffSet
int  PaddingY = 20;                                         //---- Y Padding | Spaces between each row of data.
int     AncXY = 0;                                          //---- ANCHOR OBJECT X&Y Axis Coordinates         
int PrevAncXY = 0;                                          //---- ANCHOR OBJECT PREVIOUS X&Y Axis Coordinates
//|++++++++++++++++++++++++++++++ Font Names + Font Sizes + Font Colors
string fn_All = "Arial Bold"; int fs_All = 10;                           //--- Default Object, Most Objects...
string fn_Anc = "Webdings";   int fs_Anc = 20; color fc_Anc = SteelBlue; //--- Anchor Object  | Drag Drop Object!
//|++++++++++++++++++++++++++++++ Objects Global Variables 
int iObjCount = 0;

string Sym = "";
string RootLabl = "IBFX-PRS-";
string RootAnch = "";
string PRS_Status = "";

string CompletedPatternName =""; string EmergingPatternName =""; 
string CompletedPatternTrend =""; string EmergingPatternTrend =""; 
   int CompletedPatternQuality = 0; int EmergingPatternQuality = 0;
   int CompletedPatternTime = 0; int EmergingPatternTime = 0;   
   int LastCompletedPatternTime = 0; int LastEmergingPatternTime = 0;   
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   if(IsDllsAllowed()==false) {
      Comment("DLL call is not allowed. Indicator cannot run.");
      Print("DLL call is not allowed. Indicator cannot run.");
      return(0);
   }
   
   if(ac_GetUsernameFromRegistry(Username, 100) == erINTERNALERROR) {
      Comment("Error getting username / password from registry. Please make sure the IBFX-PRS tool has previously been executed and successfully connected.");
      Print("Error getting username / password from registry. Please make sure the IBFX-PRS tool has previously been executed and successfully connected.");
      return(0);
   }
   
   if(ac_GetPasswordFromRegistry(Password, 100) == erINTERNALERROR) {
      Comment("Error getting username / password from registry. Please make sure the IBFX-PRS tool has previously been executed and successfully connected.");
      Print("Error getting username / password from registry. Please make sure the IBFX-PRS tool has previously been executed and successfully connected.");
      return(0);
   }
   
   State = STATE_STARTUP;    
   
   Sym = Symbol();                               //---- GET SYMBOL JUST ONCE
   RootAnch = StringConcatenate(RootLabl, 0);    //---- CREATE ANCHOR OBJECT NAME
   CleanUp(0);
   CreateAnchor();                               //---- CREATE ANCHOR OBJECT - WE ONLY NEED TO CREATE IT ONCE
   CreateDisplay();
   return(0);
}

int deinit() 
{
   CPSearch_Delete(SearchIndex);
   //ac_Uninit();
   int obj_total=ObjectsTotal();
   string oname;
   for(int i=obj_total-1; i>=0; i--) {
      oname=ObjectName(i);
      if(StringFind(oname,"res")>=0) {
         ObjectDelete(oname);
      }
      if(StringFind(oname,"sup")>=0) {
         ObjectDelete(oname);
      }
      if(StringFind(oname,"pred")>=0) {
         ObjectDelete(oname);
      }
   }
   CleanUp(0);
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   if(IsDllsAllowed()==false) {
      Comment("DLL call is not allowed. Expert cannot run. Please enable DLL support: Tools | Options | Expert Advisors | Allow DLL Imports");
      Print("DLL call is not allowed. Expert cannot run. Please enable DLL support: Tools | Options | Expert Advisors | Allow DLL Imports");
      return(0);
   }
   
   string sym = Symbol();
   if(StringGetChar(sym, StringLen(sym)-1) == 'm')  {
      sym = StringSubstr( sym, 0, StringLen(sym)-1) ;
   }

   switch(State) {
      case STATE_STARTUP:
         if(AccountNumber() == 0) {
            Print("Cannot load IBFX-PRS indicator, waiting for authentication by MetaTrader");   
            Comment("Cannot load IBFX-PRS indicator, waiting for authentication by MetaTrader");   
         } else {
            Print("MetaTrader authenticated, starting up indicator");   
            SetStatus(State);
            hr = ac_Initialize(StringTrimRight(StringTrimLeft(Server)), Username, Password, BrokerID, 0, "", 0, 0, "", "", 10000, 10000, 0, 0, 0, 0, debugFilename);
            ProcessResult(hr, 0);
            if(hr == erSUCCESS) {
               State = STATE_INIT;    
            }
         }
         break;
      case STATE_INIT:
         SetStatus(State);
         // fetch configuration
         hr = ac_FetchConfiguration(Config);
         error = ac_GetErrorCode();
         ProcessResult(hr, error);
         if(hr == erSUCCESS) {
            Print("Requested config");
            State = STATE_FETCHCONFIG;
            LastConnectionCheck = CurTime();
         }
         break;
      case STATE_FETCHCONFIG:
         SetStatus(State);
         hr = ac_FetchPermissions();
         error = ac_GetErrorCode();
         ProcessResult(hr, error);
         if(hr == erSUCCESS) {
            Print("Requested permissions");
            State = STATE_FETCHPERMISSIONS;
         }
         break;
      case STATE_FETCHPERMISSIONS:
         SetStatus(State);
         connected = IsAutochartistConnected();
         error = ac_GetErrorCode();
         ProcessResult(error, error);
         if(connected == 1) {
            Print("Received permissions");
            
            if(CPPermissions_GetQtySymbols() > 0) {
	            int se = CPPermissions_SymbolExists(sym);
  	          if(se  < 0) {
    	           Alert("Symbol not supported: " + sym);
      	         Comment("Symbol not supported");
        	       State = STATE_NONE; break; 
          	  }
            }

            int ie = CPPermissions_IntervalExists(Period());
            if(ie < 0) {
               Alert("Interval not supported: " + Period());
               Comment("Interval not supported");
               State = STATE_NONE; break;
            }
            string s = "FOREX:"+sym+";"+Period();
            SearchIndex = CPSearch_NewBlank(0, 0, 0, 0, "");
            hr = CPSearch_SetSearchType(SearchIndex, scSearchType_Symbols);
            hr = CPSearch_SetSymbols(SearchIndex,s);
            hr = CPSearch_SetClarity(SearchIndex, minClarity);
            hr = CPSearch_SetBreakout(SearchIndex, minBreakout);
            hr = CPSearch_SetUniformity(SearchIndex, minUniformity);
            hr = CPSearch_SetInitialTrend(SearchIndex, minInitialTrend);
            hr = CPSearch_SetPatternQuality(SearchIndex, minOverallQuality);
            hr = CPSearch_SetLength(SearchIndex, minLength);
            hr = CPSearch_SetQtyRecords(SearchIndex, (qtyCompleteToShowOnChart + qtyEmergingToShowOnChart)*2);
            hr = CPSearch_SetActive(SearchIndex, scActive_True);
            hr = CPSearch_Fetch(SearchIndex);
            error = CPSearch_GetErrorCode(SearchIndex);
            ProcessResult(hr, error);
            if(hr == erSUCCESS) {               
               TimeShift = TIMESHIFT;
               if(TimeShift<=24) 
                  Print("Time Shift is ",TimeShift," hours.");
               Print("Search for patterns on ",s,"; sIndex: ",SearchIndex);
               State = STATE_CONNECTED;
            }
         }
         break;
      case STATE_CONNECTED:
         SetStatus(State);
         if(TimeShift>24) {
            TimeShift = TIMESHIFT;
            Print("Adjusted Time Shift is ",TimeShift," hours.");
         }
         qtyComplete = CPResults_GetQtyNewComplete(SearchIndex);
         qtyEmerging = CPResults_GetQtyNewEmerging(SearchIndex);
         if((qtyComplete > 0) || (qtyEmerging > 0) && (TimeShift<=24)) {
            Print("Received results. Total=",(qtyComplete+qtyEmerging),", Complete=",qtyComplete,", Emerging=",qtyEmerging);
            DisplayChartPatterns_Initial();
            CPResults_ResetQtyResultsFound(SearchIndex);
            State = STATE_LOOP;
         }
         error = CPSearch_GetErrorCode(SearchIndex);
         ProcessResult(hr, error);
         break;
      case STATE_LOOP:
         SetStatus(State);
         //check API connection 
         if(IsAutochartistConnected()!=1) {State = STATE_INIT; break;}
         if(CurTime()-LastConnectionCheck > CONNECTION_CHECK_INTERVAL*60) {
            LastConnectionCheck = CurTime();
            hr = CPSearch_Update(SearchIndex);
            if(hr!=erSUCCESS) {
               Print("Reinitializing API...");
               State = STATE_INIT;
               break;
            }
         }
         if(TimeShift>24) {
           	TimeShift = TIMESHIFT;
            Print("Adjusted Time Shift is ",TimeShift," hours.");
         }
         qtyComplete = CPResults_GetQtyNewComplete(SearchIndex);
         qtyEmerging = CPResults_GetQtyNewEmerging(SearchIndex);
         if((qtyComplete > 0) || (qtyEmerging > 0) && (TimeShift<=24)) {
            Print("Received new results. Total=",(qtyComplete+qtyEmerging),", Complete=",qtyComplete,", Emerging=",qtyEmerging);
            DisplayChartPatterns_New();
            CPResults_ResetQtyResultsFound(SearchIndex);
         }
         error = CPSearch_GetErrorCode(SearchIndex);
         ProcessResult(hr, error);
         break;
      case STATE_ERROR:
         SetStatus(State);
         string buffer = "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890";
         ac_GetLatestError(buffer, 100);
         Comment(ProductName +" - " + buffer);
         State = STATE_TERMINATED;
         break;
      case STATE_TERMINATED:
         SetStatus(State);
         break;
   }
   
   if
   ( 
      AnchorMoved() ||
      LastCompletedPatternTime != CompletedPatternTime ||
      LastEmergingPatternTime != CompletedPatternTime || 
      PRS_Status != "" 
   )
   {
      CreateDisplay(); //---- UPDATE DISPLAY
      if( PRS_Status == "" )
      {
         LastCompletedPatternTime = CompletedPatternTime;
         LastEmergingPatternTime  = CompletedPatternTime;
      }
   }
   return(0);
}
//+------------------------------------------------------------------+
void DisplayChartPatterns_Initial()
{
   string ICname ="1234567890123456789012345678901234567890";
   string ICtrend="0987654321098765432109876543210987654321";
   string ICstr="";   
   int ICquality, ICst0;
   
   string IEname ="888888901234512345678901234567890788888";
   string IEtrend="7777754321098765432109876543210987677777";
   string IEstr="";   
   int IEquality, IEst0;
   
   int qtyPatterns = qtyComplete + qtyEmerging;
   // display the complete patterns
   int displayed = 0;
   for(int i = 0; (i < qtyPatterns) && (displayed < qtyCompleteToShowOnChart); i++) 
   {
      if(CPResults_isEmerging(SearchIndex, i) == 0) 
      {
         DisplayChartPattern(i,displayed);
         if(displayed==0) 
         {
            CPResults_GetPatternName(SearchIndex, i, ICname, 40);
            CPResults_GetTrendChange(SearchIndex, i, ICtrend, 40);
            ICst0 = CPResults_GetStartTime(SearchIndex, i) + TimeShift*60*60;
            ICquality = CPResults_GetPatternQuality(SearchIndex, i);
         }
         displayed++;
      }
   }
   
   
    
   // display the emerging patterns
   displayed = 0;
   for(i = 0; (i < qtyPatterns) && (displayed < qtyEmergingToShowOnChart); i++) {
      if(CPResults_isEmerging(SearchIndex, i) == 1) {
         DisplayChartPattern(i,displayed);
         if(displayed==0) {
            CPResults_GetPatternName(SearchIndex, i, IEname, 40);
            CPResults_GetTrendChange(SearchIndex, i, IEtrend, 40);
            IEst0 = CPResults_GetStartTime(SearchIndex, i) + TimeShift*60*60;
            IEquality = CPResults_GetPatternQuality(SearchIndex, i);
         }
         displayed++;
      }
   }
     
    EmergingPatternName = IEname;
   if( StringLen(EmergingPatternName) >=39 )
   {
      EmergingPatternName = ICname;
      EmergingPatternTrend = ICtrend;
      EmergingPatternQuality = ICquality;
      EmergingPatternTime = ICst0;  
   }
   else
   {
      EmergingPatternTrend = IEtrend;
      EmergingPatternQuality = IEquality;
      EmergingPatternTime = IEst0;  
   }
   
   CompletedPatternName = ICname;
   CompletedPatternTrend = ICtrend;
   CompletedPatternQuality = ICquality;
   CompletedPatternTime = ICst0;  
   //----
}
//+------------------------------------------------------------------+
void DisplayChartPatterns_New()
{
   string ICname="1234567890123456789012345678901234567890";
   string ICtrend="0987654321098765432109876543210987654321";
   string ICstr="";   
   int ICquality, ICst0;
   
   string IEname="888888901234512345678901234567890788888";
   string IEtrend="7777754321098765432109876543210987677777";
   string IEstr="";   
   int IEquality, IEst0;

   int totalNew = qtyComplete + qtyEmerging;
   int LastIndex = CPResults_GetQtyResults(SearchIndex)-1;
   int From = LastIndex - totalNew;
   
   // display the complete patterns
   int displayed = 0;
   for(int i = From; i<LastIndex && displayed<qtyComplete; i++) 
   {
      if(CPResults_isEmerging(SearchIndex, i) == 0 ) 
      {
         DisplayChartPattern(i,displayed);         
         if(displayed==0) 
         {
            CPResults_GetPatternName(SearchIndex, i, ICname, 40);
            CPResults_GetTrendChange(SearchIndex, i, ICtrend, 40);
            ICst0 = CPResults_GetStartTime(SearchIndex, i) + TimeShift*60*60;
            ICquality = CPResults_GetPatternQuality(SearchIndex, i);
         }
         displayed++;
      }
   }       
              
   if(qtyEmerging>0) {
      // delete old emerging patterns
      string oname = "";
      int obj_total=ObjectsTotal();
      for(i=obj_total-1; i>=0; i--) {
         oname=ObjectName(i);
         if(StringFind(oname,"em")>=0) {
            ObjectDelete(oname);
         }
      }      
   }
   // display the emerging patterns
   displayed = 0;
   for(i = From; i<LastIndex && displayed<qtyEmerging; i++) 
   {
      if(CPResults_isEmerging(SearchIndex, i) == 1) 
      {
         DisplayChartPattern(i,displayed);
         if(displayed==0) 
         {
            CPResults_GetPatternName(SearchIndex, i, IEname, 40);
            CPResults_GetTrendChange(SearchIndex, i, IEtrend, 40);
            IEst0 = CPResults_GetStartTime(SearchIndex, i) + TimeShift*60*60;
            IEquality = CPResults_GetPatternQuality(SearchIndex, i); 
         }
         displayed++;
      }
   }
   
   EmergingPatternName = IEname;
   if( StringLen(EmergingPatternName) >=39 )
   {
      EmergingPatternName = ICname;
      EmergingPatternTrend = ICtrend;
      EmergingPatternQuality = ICquality;
      EmergingPatternTime = ICst0;  
   }
   else
   {
      EmergingPatternTrend = IEtrend;
      EmergingPatternQuality = IEquality;
      EmergingPatternTime = IEst0;  
   }
   CompletedPatternName = ICname;
   CompletedPatternTrend = ICtrend;
   CompletedPatternQuality = ICquality;
   CompletedPatternTime = ICst0;  
   //----
}

//+------------------------------------------------------------------+
void DisplayChartPattern(int resultIndex, int displayed)
{
   datetime resX[2],supX[2],predX[2];
   double resY[2],supY[2],predY[2];
   string resName,supName,predName;
   double k,y0,y1,y2,y3;
   int id,x0,x1,x2,x3;
   bool isEmerging;
   
   isEmerging = (CPResults_isEmerging(SearchIndex, resultIndex) > 0);
   id = CPResults_GetResultUID(SearchIndex, resultIndex);
   if(isEmerging) {
      resName = "res."+id+".em";
      supName = "sup."+id+".em";
      predName = "pred."+id+".em";
   } 
   else {
      resName = "res."+id+".cp";
      supName = "sup."+id+".cp";
      predName = "pred."+id+".cp";
   }

   // get the datetime of each Point
   resX[0] = CPResults_GetResx0(SearchIndex, resultIndex) + TimeShift*60*60;
   resX[1] = CPResults_GetResx1(SearchIndex, resultIndex) + TimeShift*60*60;
   supX[0] = CPResults_GetSupportx0(SearchIndex, resultIndex) + TimeShift*60*60;
   supX[1] = CPResults_GetSupportx1(SearchIndex, resultIndex) + TimeShift*60*60;
   predX[0] = CPResults_GetPredTimeFrom(SearchIndex, resultIndex) + TimeShift*60*60;
   predX[1] = CPResults_GetPredTimeTo(SearchIndex, resultIndex) + TimeShift*60*60;
      
   //get the price of each point
   resY[0] = CPResults_GetResy0(SearchIndex, resultIndex);
   resY[1] = CPResults_GetResy1(SearchIndex, resultIndex);
   supY[0] = CPResults_GetSupporty0(SearchIndex, resultIndex);
   supY[1] = CPResults_GetSupporty1(SearchIndex, resultIndex);

   if(DrawFromCurrentPrice) {
      //get price from the current chart
      resY[0] = High[iBarShift(NULL,0,resX[0])];
      resY[1] = High[iBarShift(NULL,0,resX[1])];
      supY[0] = Low[iBarShift(NULL,0,supX[0])];
      supY[1] = Low[iBarShift(NULL,0,supX[1])];
   }

   predY[0] = CPResults_GetPredPriceFrom(SearchIndex, resultIndex);
   predY[1] = CPResults_GetPredPriceTo(SearchIndex, resultIndex);

   x3 = iBarShift(NULL,0,CPResults_GetEndTime(SearchIndex, resultIndex) + TimeShift*60*60);
   x0 = iBarShift(NULL,0,CPResults_GetStartTime(SearchIndex, resultIndex) + TimeShift*60*60);

   //extend trend lines in the future
   x1 = iBarShift(NULL,0,resX[0]);
   x2 = iBarShift(NULL,0,resX[1]); 
   y1 = resY[0]; 
   y2 = resY[1];
   if(x1-x2>0) {
      y0 = ((x2-x0)/1.0/(x2-x1))*(y1-y2)+y2;
      y3 = ((x3-x2)/1.0/(x2-x1))*(y2-y1)+y2;
      resX[1] = Time[x3]; resY[1] = y3;
   }
   //--------
   x1 = iBarShift(NULL,0,supX[0]); 
   x2 = iBarShift(NULL,0,supX[1]); 
   y1 = supY[0]; 
   y2 = supY[1];
   if(x1-x2>0) {
      y0 = ((x2-x0)/1.0/(x2-x1))*(y1-y2)+y2;
      y3 = ((x3-x2)/1.0/(x2-x1))*(y2-y1)+y2;
      supX[1] = Time[x3]; supY[1] = y3;
   }
   
   if(ObjectFind(resName)==-1) {
      //resBuf[iBarShift(NULL,0,resX[0])] = resY[0];
      //resBuf[iBarShift(NULL,0,resX[1])] = resY[1];
      ObjectCreate(resName,OBJ_TREND,0,resX[0],resY[0],resX[1],resY[1]);
      ObjectSet(resName,OBJPROP_WIDTH,2);
      ObjectSet(resName,OBJPROP_RAY,false);
      if(isEmerging) {
         ObjectSet(resName,OBJPROP_STYLE,STYLE_DASH);
         ObjectSet(resName,OBJPROP_COLOR,EmergingColor);
      }
      else{
            ObjectSet(resName,OBJPROP_COLOR,CompletedColor);
      }
   } else {
      ObjectSet(resName,OBJPROP_TIME1,resX[0]);
      ObjectSet(resName,OBJPROP_PRICE1,resY[0]);
      ObjectSet(resName,OBJPROP_TIME2,resX[1]);
      ObjectSet(resName,OBJPROP_PRICE2,resY[1]);
   }
   if(ObjectFind(supName)==-1) {
      
      ObjectCreate(supName,OBJ_TREND,0,supX[0],supY[0],supX[1],supY[1]);
      ObjectSet(supName,OBJPROP_WIDTH,2);
      ObjectSet(supName,OBJPROP_RAY,false);
      if(isEmerging) {
         ObjectSet(supName,OBJPROP_STYLE,STYLE_DASH);
         ObjectSet(supName,OBJPROP_COLOR,EmergingColor);
      }
      else{
            ObjectSet(supName,OBJPROP_COLOR,CompletedColor);
      }
   } else {
      ObjectSet(supName,OBJPROP_TIME1,supX[0]);
      ObjectSet(supName,OBJPROP_PRICE1,supY[0]);
      ObjectSet(supName,OBJPROP_TIME2,supX[1]);
      ObjectSet(supName,OBJPROP_PRICE2,supY[1]);
   }
   if(!isEmerging && displayed==0) {
      if(ObjectFind(predName)==-1) {   
         ObjectCreate(predName,OBJ_RECTANGLE,0,predX[0],predY[0],predX[1],predY[1]);      
         ObjectSet(predName,OBJPROP_COLOR,CompletedColor);
      } else {
         ObjectSet(predName,OBJPROP_TIME1,predX[0]);
         ObjectSet(predName,OBJPROP_PRICE1,predY[0]);
         ObjectSet(predName,OBJPROP_TIME2,predX[1]);
         ObjectSet(predName,OBJPROP_PRICE2,predY[1]);  
      }
   }     
}

void SetStatus(int status)
{
   switch(status) {
      case STATE_NONE:
         PRS_Status = ProductName +" - Initialized";
         break;
      case STATE_STARTUP:
         PRS_Status = ProductName +" - Starting up                ";
         break;
      case STATE_INIT:
         PRS_Status = ProductName +" - Waiting for streaming quotes.   ";
         break;
      case STATE_FETCHCONFIG:
         PRS_Status = ProductName +" - Connecting...            ";
         break;
      case STATE_FETCHPERMISSIONS:
         PRS_Status = ProductName +" - Connecting...            ";
         break;
      case STATE_CONNECTED:
         PRS_Status = ProductName +" - Fetching Chart Patterns...      ";
         break;
      case STATE_LOOP:
         PRS_Status = "";
         break;
      case STATE_ERROR:
         PRS_Status = ProductName +" - Error. See Expert Log";
         break;
      case STATE_TERMINATED:
         PRS_Status = ProductName +" - Terminated. See Expert Log";
         break;
   }
}


int ProcessResult(int hr, int error)
{
   if(hr == 0) return(0);  
   switch(hr) {
   case erINTERNALERROR:
          Print("Internal error");
          State = STATE_ERROR;
          break;
   case erSTRINGTRUNCATED:
          Print("String truncated");
          break;
   case erSEARCHOBJECTHASNORESULTS:
          Print("No results");
          break;
   case erINVALIDCHARTPATTERNSEARCH:
          Print("Inavlid search object");
          State = STATE_ERROR;
          break;
   case erINVALIDCHARTPATTERNRESULT:
          Print("Invalid result");
          break;
   case erNOTINITIALIZED:
          Print("Not initialized");
          break;
   case erINDEXOUTOFBOUNDS:
          Print("Index out of bounds");
          State = STATE_ERROR;
          break;
   case erITEMNOTFOUND:
          Print("Item not found");
          break;
   case erABORT:
          Print("User abort");
          break;
   case erNOPERMISSIONS:
          Print("No permissions");
          State = STATE_ERROR;
          break;
   case erUNKNOWNTIMEZONE:
          Print("Unknown timezone");
          break;
   case erTIMECONVERSIONERROR:
          Print("Time conversion error");
          break;
   case erINVALIDCHARTPATTERNIMAGE:
          Print("Invalid chart pattern image");
          break;
   case erBUFFERTRUNCATED:
          Print("Buffer truncated");
          State = STATE_ERROR;
          break;
   case erIMAGENOTDOWNLOADED:
          Print("Image not downloaded");
          break;
   case erIMAGECONVERSIONERROR:
          Print("Image conversion error");
          break;
   case erINVALIDCHARTPATTERNDATA:
          Print("Invalid chart pattern data");
          State = STATE_ERROR;
          break;
   case erNOINTERNETCONNECTIONEXCEPTION:
          Print("No internet connection");
          break;
   case erDATACORRUPTEXCEPTION:
          Print("Data corrupt");
          State = STATE_ERROR;
          break;
   case erINVALIDVALUESPECIFIED:
          Print("Invalid value specified");
          State = STATE_ERROR;
          break;
   case erVALUENOTSPECIFIEDEXCEPTION:
          Print("Value not specified");
          State = STATE_ERROR;
          break;
   case erINTERNALEXCEPTION:
          Print("Internal exception");
          State = STATE_ERROR;
          break;
   case erCOMMUNICATIONEXCEPTION:
          Print("Communication error");
          break;
   case erSERVICENOTAVAILABLEEXCEPTION:
          Print("service not available");
          break;
   case erUKNOWNEXCEPTION:
          Print("Unknown Exception");
          State = STATE_ERROR;
          break;
   case erREQUESTTOOSOONEXCEPTION:
          Print("Request too soon");
          break;
   case erIMAGECONVERSIONEXCEPTION:
          Print("Image conversion");
          break;
   case erAUTHFROMDIFFERENTMACHINE:
          Print("Auth from different location");
          State = STATE_ERROR;
          break;
   case erINSUFFICIENTPERMISSIONS:
          Print("Insufficient permissions");
          State = STATE_ERROR;
          break;
   case erSAVINGIMAGEEXCEPTION:
          Print("Error saving image");
          break;
   case erSAVINGDATAEXCEPTION:
          Print("Error saving data");
          break;
   case erINVALIDRESULTEXCEPTION:
          Print("Invalid result");
          break;
   case erCONFIGNOTDOWNLOADEDEXCEPTION:
          Print("Config not downloaded");
          break;
   case erFORCEUPGRADEEXCEPTION:
          Print("Force upgrade");
          State = STATE_ERROR;
          break;
   case erIMAGENOTDOWNLOADEDEXCEPTION:
          Print("Image not downlaoded");
          break;
   }
   if(error != 0) {
          if((State > STATE_INIT) && (State < STATE_CONNECTED)) {
                  State--;
          }
   }
   return (1);
}
//+------------------------------------------------------------------+
//| CreateAnchor                                                     |
//+------------------------------------------------------------------+
void CreateAnchor() 
{     
   Label("2", LastX(), LastY(), fs_Anc, fn_Anc, fc_Anc, Window, Corner ); 
}
//+------------------------------------------------------------------+
//+---------------------------------------------------------------------------------------------------------------+
//+ ObjectMakeLabel                                                                                               +
//+---------------------------------------------------------------------------------------------------------------+
void Label(string t,int x,int y,int s,string f,color c,int w, int Corner)
{
   string n = sObjName( iObjCount);
   ObjectCreate( n, OBJ_LABEL, w, 0, 0 );
      ObjectSet( n, OBJPROP_CORNER, Corner );
      ObjectSet( n, OBJPROP_XDISTANCE, x );
      ObjectSet( n, OBJPROP_YDISTANCE, y );
      ObjectSet( n, OBJPROP_BACK, False );
  ObjectSetText( n, t, s, f, c );
  iObjCount++;
 } 
//+---------------------------------------------------------------------------------------------------------------+
//+---------------------------------------------------------------------------------------------------------------+
//+ Anchor Moved?
//+---------------------------------------------------------------------------------------------------------------+
bool AnchorMoved()
{
   AncXY = ObjectGet( RootAnch, OBJPROP_XDISTANCE) * ObjectGet( RootAnch , OBJPROP_YDISTANCE );
   if( AncXY != PrevAncXY ) { PrevAncXY = AncXY; return(True); }
   else                                { return(False); }
}
//+---------------------------------------------------------------------------------------------------------------+
//+---------------------------------------------------------------------------------------------------------------+
//+ Find Y OffSet                                                                                                 +
//+---------------------------------------------------------------------------------------------------------------+
int LastY(){string n=StringConcatenate(RootLabl,iObjCount-1); int Y=ObjectGet( n, OBJPROP_YDISTANCE ); return(Y); }
//+---------------------------------------------------------------------------------------------------------------+

//+---------------------------------------------------------------------------------------------------------------+
//+ FindX OffSet                                                                                                  +
//+---------------------------------------------------------------------------------------------------------------+
int LastX()
{
   if( ObjectFind( RootAnch ) == -1 ) { return(Width+OffXet); }
   else 
   {
      return(ObjectGet( RootAnch, OBJPROP_XDISTANCE )-Width+OffXet ); 
   }
}
//+---------------------------------------------------------------------------------------------------------------+

//+---------------------------------------------------------------------------------------------------------------+
//+ sObjectName()                                                                                                 +
//+---------------------------------------------------------------------------------------------------------------+
string sObjName(int sObj){ return( StringConcatenate(RootLabl,sObj )); }
//+---------------------------------------------------------------------------------------------------------------+

  
//+---------------------------------------------------------------------------------------------------------------+
//+ Cleanup()                                                                                                     +
//+---------------------------------------------------------------------------------------------------------------+
void CleanUp(int Start ) 
{  
   Comment(""); int iDel = Start; 
   string Name = sObjName( iDel ); 
   
   while( ObjectFind(Name) != -1 )
   { 
      ObjectDelete(Name); 
      iDel++; 
      Name = sObjName( iDel ); 
   }
}
//+---------------------------------------------------------------------------------------------------------------+
//+---------------------------------------------------------------------------------------------------------------+
//+                                                CreateHorzLine                                                 +
//+---------------------------------------------------------------------------------------------------------------+
void HLine( int x, int y){ Label("__________________________",x,y,6,"system",DarkGray,Window, Corner);  }
//+---------------------------------------------------------------------------------------------------------------+

//+---------------------------------------------------------------------------------------------------------------+
//+                                                CreateHorzLine                                                 +
//+---------------------------------------------------------------------------------------------------------------+
void HDottedLine( int x, int y){ Label("....................................................",x,y,6,"system",DarkGray,Window, Corner);  }
//+---------------------------------------------------------------------------------------------------------------+

void CreateDisplay()
{
   iObjCount = 1;
   CleanUp(1);
   
   //----
   HLine( LastX()+10, LastY()+10);    
   Label( "IBFX-PRS v.["+DoubleToStr(VERSION,2)+"]",LastX()+70, LastY()+20, 7, fn_All, TEXT_COLOR, Window, Corner );
   HLine( LastX()+10, LastY()+2);   
   //----
   if( PRS_Status != "" && PRS_Status != ProductName +" - Fetching Chart Patterns...      " )
   {
      Label( PRS_Status,LastX()+10, LastY()+25, 7, fn_All, LABEL_COLOR, Window, Corner );  
   }
   else
   {
      //---- Completed
      Label( "Last Completed Pattern",  LastX()+10,LastY()+20, fs_All, fn_All, TITLE_COLOR, Window, Corner );  
      HDottedLine( LastX()+10, LastY()+10);    
      
      if( CompletedPatternName == "" ) { CompletedPatternName = "No Pattern Found!"; }
      Label( "Pattern:",  LastX()+150,LastY()+20, fs_All, fn_All, LABEL_COLOR, Window, Corner );  
         Label( CompletedPatternName,  LastX()+10,LastY(), fs_All, fn_All, TEXT_COLOR, Window, Corner );
           
      Label( "Trend:",  LastX()+150,LastY()+20, fs_All, fn_All, LABEL_COLOR, Window, Corner );     
         Label( CompletedPatternTrend, LastX()+10,LastY(), fs_All, fn_All, TEXT_COLOR, Window, Corner ); 
      
      Label( "Quality:",  LastX()+150,LastY()+20, fs_All, fn_All, LABEL_COLOR, Window, Corner );              
         Label( StringSubstr( " §§§§§§§§§§", 0, CompletedPatternQuality), LastX()+10, LastY(), fs_All+2, "Wingdings", OrangeRed, Window, Corner );  
      
      Label( "Time:",  LastX()+150,LastY()+20, fs_All, fn_All, LABEL_COLOR, Window, Corner );               
         Label( TimeToStr( CompletedPatternTime, TIME_DATE | TIME_MINUTES ), LastX()+10, LastY(), fs_All, fn_All, LABEL_COLOR, Window, Corner );  
         
      //---- Emerging
      HLine( LastX()+10, LastY()+10);    
      Label( "Last Emerging Pattern",  LastX()+10,LastY()+20, fs_All, fn_All, TITLE_COLOR, Window, Corner );  
      HDottedLine( LastX()+10, LastY()+10);    
      
      if( EmergingPatternName == "" || EmergingPatternTime == 0 ) 
      { 
            EmergingPatternName = "No Pattern Found!"; 
           EmergingPatternTrend = "";
         EmergingPatternQuality = 0;
      }
      
         Label( "Pattern:",  LastX()+150,LastY()+20, fs_All, fn_All, LABEL_COLOR, Window, Corner );  
            Label( EmergingPatternName,  LastX()+10,LastY(), fs_All, fn_All, TEXT_COLOR, Window, Corner );
           
         Label( "Trend:",  LastX()+150,LastY()+20, fs_All, fn_All, LABEL_COLOR, Window, Corner );     
            Label( EmergingPatternTrend, LastX()+10,LastY(), fs_All, fn_All, TEXT_COLOR, Window, Corner ); 
      
         Label( "Quality:",  LastX()+150,LastY()+20, fs_All, fn_All, LABEL_COLOR, Window, Corner );              
            Label( StringSubstr( " §§§§§§§§§§", 0, EmergingPatternQuality), LastX()+10, LastY(), fs_All+2, "Wingdings", OrangeRed, Window, Corner );  
      
         Label( "Time:",  LastX()+150,LastY()+20, fs_All, fn_All, LABEL_COLOR, Window, Corner );               
            Label( TimeToStr( EmergingPatternTime, TIME_DATE | TIME_MINUTES ), LastX()+10, LastY(), fs_All, fn_All, LABEL_COLOR, Window, Corner );  
            
   }
   
   if( DisplayFilters )
   {
      HLine( LastX()+10, LastY()+10);    
      Label( "Filters",  LastX()+100,LastY()+20, fs_All, fn_All, TITLE_COLOR, Window, Corner );  
      HDottedLine( LastX()+10, LastY()+10); 
      
      Label( "Min Quality:",  LastX()+100,LastY()+20, fs_All, fn_All, LABEL_COLOR, Window, Corner );              
         Label( StringSubstr( " §§§§§§§§§§", 0, MathMax( minOverallQuality+1, 1 ) ), LastX()+20, LastY(), fs_All+2, "Wingdings", RoyalBlue, Window, Corner ); 

      Label( "Min InitialTrend:",  LastX()+100,LastY()+20, fs_All, fn_All, LABEL_COLOR, Window, Corner );              
         Label( StringSubstr( " §§§§§§§§§§", 0, MathMax( minInitialTrend+1, 1 ) ), LastX()+20, LastY(), fs_All+2, "Wingdings", MediumSeaGreen, Window, Corner ); 
     
      Label( "Min Uniformity:",  LastX()+100,LastY()+20, fs_All, fn_All, LABEL_COLOR, Window, Corner );              
         Label( StringSubstr( " §§§§§§§§§§", 0, MathMax( minUniformity+1, 1 ) ), LastX()+20, LastY(), fs_All+2, "Wingdings", Gold, Window, Corner ); 

      Label( "Min Clarity:",  LastX()+100,LastY()+20, fs_All, fn_All, LABEL_COLOR, Window, Corner );              
         Label( StringSubstr( " §§§§§§§§§§", 0, MathMax( minClarity+1, 1 )  ), LastX()+20, LastY(), fs_All+2, "Wingdings", OrangeRed, Window, Corner ); 

      Label( "Min Breakout:",  LastX()+100,LastY()+20, fs_All, fn_All, LABEL_COLOR, Window, Corner );              
         Label( StringSubstr( " §§§§§§§§§§", 0, MathMax( minBreakout+1, 1 ) ), LastX()+20, LastY(), fs_All+2, "Wingdings", Indigo, Window, Corner );       
      
      Label( "Min Length:",  LastX()+100,LastY()+20, fs_All, fn_All, LABEL_COLOR, Window, Corner );              
         Label( StringSubstr( " §§§§§§§§§§", 0, MathMax( minLength+1, 1 ) ), LastX()+20, LastY(), fs_All+2, "Wingdings", LABEL_COLOR, Window, Corner ); 
   }
   //----
   HLine( LastX()+10, LastY()+10);    
   Label( "www.InterbankFX.com",LastX()+60, LastY()+20, 7, fn_All, Crimson, Window, Corner );
   HLine( LastX()+10, LastY()+2);   
   //----
}
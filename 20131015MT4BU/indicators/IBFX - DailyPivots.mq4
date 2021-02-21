#property copyright "Copyright - Interbank FX, LLC."
#property link      "http://www.ibfx.com"

#property indicator_chart_window
#property indicator_buffers 7


#property indicator_color1 Maroon
#property indicator_color2 Crimson
#property indicator_color3 Crimson
#property indicator_color4 OrangeRed
#property indicator_color5 Green
#property indicator_color6 Green
#property indicator_color7 DarkGreen

#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_DASH
#property indicator_style3 STYLE_DASH
#property indicator_style4 STYLE_SOLID
#property indicator_style5 STYLE_DASH
#property indicator_style6 STYLE_DASH
#property indicator_style7 STYLE_SOLID

#property indicator_width1 5
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 5
#property indicator_width5 1
#property indicator_width6 1
#property indicator_width7 5

//+------------------------------------------------------------------+
//| Custom indicator user inputs                                     |
//+------------------------------------------------------------------+
extern int     Offset = 1;
extern int   BarCount = 10;
extern color R3_Color = Maroon;
extern color R2_Color = Crimson;
extern color R1_Color = Crimson;
extern color Pivot_Color = OrangeRed;
extern color S1_Color = Green;
extern color S2_Color = Green;
extern color S3_Color = DarkGreen;
//+------------------------------------------------------------------+
//| Custom indicator global variables                                |
//+------------------------------------------------------------------+
datetime CurrTime = 0;
datetime PrevTime = 0;

string StrR3Value = "";
string StrR2Value = "";
string StrR1Value = "";
string StrPivotValue = "";
string StrS1Value = "";
string StrS2Value = "";
string StrS3Value = "";
string        Sym = "";

double rates_d1[][6];
double R3_0[],R2_0[],R1_0[],R0_5[],Pivot[],S1_0[],S2_0[],S3_0[];

//|++++++++++++++++++++++++++++++ General OBJECTS Variables
string  RootName = "IBFX-DailyPivots";                      //----
string  RootLabl = "";
string  RootAnch = "";
int iObjCount = 0;

//|++++++++++++++++++++++++++++++ Display Settings
extern int    Window = 0;                                          //---- SELECT WINDOW FOR INDICATOR 0 = MainChart...
int    Corner = 1;                                          //---- SELECT CORNER FOR INDICATOR 1 = TopRight ...
int     Width = 80;                                        //---- WIDTH OF MAIN DISPLAY
int    OffXet = 5;                                          //---- X-Axis OffSet
int    OffYet = 3;                                          //---- Y-Axis OffSet
int  PaddingY = 20;                                         //---- Y Padding | Spaces between each row of data.
int     AncXY = 0;                                          //---- ANCHOR OBJECT X&Y Axis Coordinates
int PrevAncXY = 0;                                          //---- ANCHOR OBJECT PREVIOUS X&Y Axis Coordinates

//|++++++++++++++++++++++++++++++ Font Names + Font Sizes + Font Colors
string fn_All = "Arial Bold"; int fs_All = 10;                           //--- Default Object, Most Objects...
string fn_Anc = "Webdings";   int fs_Anc = 20; color fc_Anc = SteelBlue; //--- Anchor Object  | Drag Drop Object!

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
Sym = Symbol();                               //---- GET SYMBOL JUST ONCE
RootLabl = RootName+"-Daily-";                     //---- CREATE OBJECT NAME ROOT
RootAnch = StringConcatenate(RootLabl, 0);         //---- CREATE ANCHOR OBJECT NAME
PrevTime = 0;
if( ObjectFind( sObjName(0) ) == -1 ) { CleanUp(0); CreateAnchor(); }
else                                  { CleanUp(1); }

//---- Set Index Buffers / Set Index Labels
SetIndexBuffer(  0 , R3_0);   SetIndexLabel(  0, "R3" );   SetIndexStyle( 0, DRAW_LINE, STYLE_SOLID, 2, R3_Color );
//SetIndexBuffer(  1 , R2_5);   SetIndexLabel(  1, "R2.5" ); SetIndexStyle( 1, DRAW_LINE, STYLE_DOT, 1, Orchid);
SetIndexBuffer(  1 , R2_0);   SetIndexLabel(  1, "R2" );   SetIndexStyle( 1, 0, STYLE_DASH, 1, R2_Color);
//SetIndexBuffer(  3 , R1_5);   SetIndexLabel(  3, "R1.5" ); SetIndexStyle( 3, DRAW_LINE, STYLE_DOT, 1, Orchid);
SetIndexBuffer(  2 , R1_0);   SetIndexLabel(  2, "R1" );   SetIndexStyle( 2, DRAW_LINE, STYLE_DASH, 1, R1_Color);
//SetIndexBuffer(  5 , R0_5);   SetIndexLabel(  5, "R0.5" ); SetIndexStyle( 5, DRAW_LINE, STYLE_DOT, 1, Orchid);
SetIndexBuffer(  3 , Pivot);  SetIndexLabel(  3, "Pivot" );SetIndexStyle( 3, DRAW_LINE, STYLE_SOLID, 2, Pivot_Color);
//SetIndexBuffer(  7 , S0_5);   SetIndexLabel(  7, "S0.5" ); SetIndexStyle( 7, DRAW_LINE, STYLE_DOT, 1, LawnGreen);
SetIndexBuffer(  4 , S1_0);   SetIndexLabel(  4, "S1" );   SetIndexStyle( 4, DRAW_LINE, STYLE_DASH, 1, S1_Color);
//SetIndexBuffer(  9 , S1_5);   SetIndexLabel(  9, "S1.5" ); SetIndexStyle( 9, DRAW_LINE, STYLE_DOT, 1, LawnGreen);
SetIndexBuffer( 5 , S2_0);   SetIndexLabel( 5, "S2" );   SetIndexStyle( 5, DRAW_LINE, STYLE_DASH, 1, S2_Color);
//SetIndexBuffer( 11 , S2_5);   SetIndexLabel( 11, "S2.5" ); SetIndexStyle( 11, DRAW_LINE, STYLE_DOT, 1, LawnGreen);
SetIndexBuffer( 6 , S3_0);   SetIndexLabel( 6, "S3" );   SetIndexStyle( 6, DRAW_LINE, STYLE_SOLID, 2, S3_Color);
//----
return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
switch( UninitializeReason() )
{
case  REASON_PARAMETERS:
case   REASON_RECOMPILE:
case REASON_CHARTCHANGE:
case  REASON_PARAMETERS:
CleanUp(1);
break;
case  REASON_CHARTCLOSE:
case      REASON_REMOVE:
default:
CleanUp(0);
break;
}
return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
datetime CurrTime = iTime(Sym,PERIOD_D1,1);

if( CurrTime != PrevTime )
{
ArrayCopyRates(rates_d1, Sym, PERIOD_D1);

int Iteration = Offset;
int OffSetDayOfWeek = TimeDayOfWeek( iTime(Sym, PERIOD_D1, Offset) );

if( OffSetDayOfWeek == 0 ) { Iteration = Offset + 1; }

int Precision = MarketInfo( Sym, MODE_DIGITS );

double yesterday_close = rates_d1[Iteration][4];
double yesterday_open = rates_d1[Iteration][1];
double yesterday_high = rates_d1[Iteration][3];
double yesterday_low = rates_d1[Iteration][2];

int counted_bars=IndicatorCounted();
if(counted_bars<0) { return(-1); }
if(counted_bars>0) { counted_bars--; }
int Limit = Bars-counted_bars;

for( int i = MathMax(MathMin(Limit, BarCount )-1,0); i >= 0; i-- )
{
Pivot[i] = ( yesterday_high + yesterday_low + yesterday_close ) / 3.0 ;
R1_0[i] = ( 2.0 * Pivot[i] ) - yesterday_low;
S1_0[i] = ( 2.0 * Pivot[i] ) - yesterday_high;
R2_0[i] = Pivot[i] + ( R1_0[i] - S1_0[i] );
S2_0[i] = Pivot[i] - ( R1_0[i] - S1_0[i] );
R3_0[i] = ( 2.0 * Pivot[i] ) + ( yesterday_high - ( 2.0 * yesterday_low ) );
S3_0[i] = ( 2.0 * Pivot[i] ) - ( ( 2.0 * yesterday_high ) - yesterday_low );
//R0_5[i] = ( Pivot[i] + R1_0[i] ) / 2.0;
//S0_5[i] = ( Pivot[i] + S1_0[i] ) / 2.0;
//R1_5[i] = (  R1_0[i] + R2_0[i] ) / 2.0;
//S1_5[i] = (  S1_0[i] + S2_0[i] ) / 2.0;
//R2_5[i] = (  R2_0[i] + R3_0[i] ) / 2.0;
//S2_5[i] = (  S2_0[i] + S3_0[i] ) / 2.0;
}

StrR3Value = DoubleToStr( R3_0[0], Precision );
StrR2Value = DoubleToStr( R2_0[0], Precision );
StrR1Value = DoubleToStr( R1_0[0], Precision );
StrPivotValue = DoubleToStr( Pivot[0], Precision );
StrS1Value = DoubleToStr( S1_0[0], Precision );
StrS2Value = DoubleToStr( S2_0[0], Precision );
StrS3Value = DoubleToStr( S3_0[0], Precision );
}
if( AnchorMoved() || ObjectFind( sObjName(13) ) == -1 ) { CreateDisplay(); }
//----
return(0);
}
//+------------------------------------------------------------------+

//+---------------------------------------------------------------------------------------------------------------+
//+ Cleanup()                                                                                                     +
//+---------------------------------------------------------------------------------------------------------------+
void CleanUp( int iDel )
{
Comment("");
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
return(ObjectGet( RootAnch, OBJPROP_XDISTANCE )-160+OffXet );
}
}
//+---------------------------------------------------------------------------------------------------------------+

//+---------------------------------------------------------------------------------------------------------------+
//+ sObjectName()                                                                                                 +
//+---------------------------------------------------------------------------------------------------------------+
string sObjName(int sObj){ return( StringConcatenate(RootLabl,sObj )); }
//+---------------------------------------------------------------------------------------------------------------+

//+---------------------------------------------------------------------------------------------------------------+
//| CreateAnchor                                                                                                  |
//+---------------------------------------------------------------------------------------------------------------+
void CreateAnchor()
{
Label("2", LastX(), LastY(), fs_Anc, fn_Anc, fc_Anc, Window, Corner );
}
//+---------------------------------------------------------------------------------------------------------------+

//+---------------------------------------------------------------------------------------------------------------+
//| CreateDisplay                                                                                                 |
//+---------------------------------------------------------------------------------------------------------------+
void CreateDisplay()
{
int       cX = LastX();
int       cY = LastY()+200;
iObjCount = 1;
HLine(cX+80, LastY());
Label("IBFX - DAILY PIVOTS",   cX+83,LastY()+20,6, fn_All,DarkGray,Window,Corner);
HLine(cX+80, LastY());
Label("R3 - "    + StrR3Value,   cX+87,LastY()+20,fs_All, fn_All,R3_Color,Window,Corner);
Label("R2 - "    + StrR2Value,   cX+87,LastY()+20,fs_All, fn_All,R2_Color,Window,Corner);
Label("R1 - "    + StrR1Value,   cX+87,LastY()+20,fs_All, fn_All,R1_Color,Window,Corner);
Label("Pivot - " + StrPivotValue,cX+87,LastY()+20,fs_All, fn_All,Pivot_Color,Window,Corner);
Label("S1 - "    + StrS1Value,   cX+87,LastY()+20,fs_All, fn_All,S1_Color,Window,Corner);
Label("S2 - "    + StrS2Value,   cX+87,LastY()+20,fs_All, fn_All,S2_Color,Window,Corner);
Label("S3 - "    + StrS3Value,   cX+87,LastY()+20,fs_All, fn_All,S3_Color,Window,Corner);
HLine(cX+80, LastY()+5);
}
//+---------------------------------------------------------------------------------------------------------------+

//+---------------------------------------------------------------------------------------------------------------+
//+                                                CreateHorzLine                                                 +
//+---------------------------------------------------------------------------------------------------------------+
void HLine( int x, int y){ Label("__________",x,y,6,"system",DarkGray,Window, Corner);  }
//+---------------------------------------------------------------------------------------------------------------+

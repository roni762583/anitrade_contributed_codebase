//+------------------------------------------------------------------+
//|                                                Aharon_ATR_t1.mq4 |
//|                                                           Aharon |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
//
#property copyright "me"
#property link      "http://www.metaquotes.net/"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 DodgerBlue
//---- input parameters
extern int AtrPeriod=1;
//---- buffers
double AtrBuffer[];
double TempBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- 1 additional buffer used for counting.
   IndicatorBuffers(2);
//---- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,AtrBuffer);
   SetIndexBuffer(1,TempBuffer);
//---- name for DataWindow and indicator subwindow label
   short_name="Aharon_ATR_t1("+AtrPeriod+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
//----
   SetIndexDrawBegin(0,AtrPeriod);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Average True Range                                               |
//+------------------------------------------------------------------+
int start()
  {
   int i,counted_bars=IndicatorCounted();
//----
   if(Bars<=AtrPeriod) return(0);
//---- initial zero
   if(counted_bars<1)
      for(i=1;i<=AtrPeriod;i++) AtrBuffer[Bars-i]=0.0;
//----
   i=Bars-counted_bars-1;                    //# of changed/'new' bars only

   while(i>=0)
     {
      double high=High[i];
      double low =Low[i];
      double open=Open[i];                   /////////////////I added
      double close=Close[i];                 /////////////////I added
      if(i==Bars-1) {                        //In the case no bars are unchanged (i.e. all 'new'bars as in initial run)
         TempBuffer[i]=close-open;        //TempBuffer[i]=high-low; 
// Alert("i = ", i);
      }
      else
        {
         double prevclose=Close[i+1];
         TempBuffer[i]=MathMax(high,prevclose)-MathMin(low,prevclose);
        
        }
      i--;
     }
//----
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   for(i=0; i<limit; i++)
      AtrBuffer[i]= iMAOnArray(TempBuffer,Bars,AtrPeriod,0,MODE_SMA,i);
//

   for(i=0; i<limit; i++) {
//----
   return(0);
  }
//+------------------------------------------------------------------+
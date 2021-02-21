//+------------------------------------------------------------------+
//|                                        Aharon_10_MAs_Aligned.mq4 |
//|                      Copyright © 2009, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 DodgerBlue
#property indicator_color2 Pink
#property indicator_color3 Red
#property indicator_color4 Yellow
#property indicator_color5 Green

extern int AvgLen = 3;

//---- buffers
double AtrBuffer[];
double TempBuffer[];
double SumBuffer[];
double AvgSum[];
double Gap[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;

   IndicatorBuffers(5);
//---- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexStyle(4,DRAW_LINE);
   
   SetIndexDrawBegin(4, 100);
   
   SetIndexBuffer(0,AtrBuffer);
   SetIndexBuffer(1,TempBuffer);
   SetIndexBuffer(2,SumBuffer);
   SetIndexBuffer(3,AvgSum);
   SetIndexBuffer(4,Gap);
//---- name for DataWindow and indicator subwindow label
   short_name="Aharon_10_MAs_Aligned("+AvgLen+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"ups");
   SetIndexLabel(1,"downs");
   SetIndexLabel(2,"sum");
   SetIndexLabel(3,"Avg_Sum");
   SetIndexLabel(4,"Gap");
//----
   
   return(0);
  }
  
  
  
//+------------------------------------------------------------------+
//| Start                                             |
//+------------------------------------------------------------------+
int start()
  {
   int i,counted_bars=IndicatorCounted();
//-
//----
   i=Bars-counted_bars-1;
  
//----
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   double u1=0.0, u2=0.0, u3=0.0, u4=0.0, u5=0.0, u6=0.0, u7=0.0, d1=0.0, d2=0.0, d3=0.0, d4=0.0, d5=0.0, d6=0.0, d7=0.0;
   
   for(i=0; i<limit; i++) {
   
      
      u1=0.0;
      u2=0.0;
      u3=0.0;
      u4=0.0;
      u5=0.0;
      u6=0.0;
      u7=0.0;
      
      d1=0.0;
      d2=0.0;
      d3=0.0;
      d4=0.0;
      d5=0.0;
      d6=0.0;
      d7=0.0;
      
      //down movement
      if(    
         iMA(NULL, 0, 4, 0, MODE_SMA, PRICE_CLOSE, i)>iMA(NULL, 0, 2, 0, MODE_SMA, PRICE_CLOSE, i)
       ) d1 = 1.0;
       
      if(    
         iMA(NULL, 0, 6, 0, MODE_SMA, PRICE_CLOSE, i)>iMA(NULL, 0, 4, 0, MODE_SMA, PRICE_CLOSE, i)
       ) d2 = 1.0;  
        
      if(  
         iMA(NULL, 0, 8, 0, MODE_SMA, PRICE_CLOSE, i)>iMA(NULL, 0, 6, 0, MODE_SMA, PRICE_CLOSE, i) 
       ) d3 = 1.0; 
        
      if(  
         iMA(NULL, 0, 10, 0, MODE_SMA, PRICE_CLOSE, i)>iMA(NULL, 0, 8, 0, MODE_SMA, PRICE_CLOSE, i) 
       ) d4 = 1.0; 
       
       
      // half point for 'two' averages removed, in order
      if( false 
        // iMA(NULL, 0, 10, 0, MODE_SMA, PRICE_CLOSE, i)>iMA(NULL, 0, 6, 0, MODE_SMA, PRICE_CLOSE, i) 
       ) d5 = 0.5; 
      
      if(  false
        // iMA(NULL, 0, 8, 0, MODE_SMA, PRICE_CLOSE, i)>iMA(NULL, 0, 4, 0, MODE_SMA, PRICE_CLOSE, i) 
       ) d6 = 0.5;
       
      if(  
         iMA(NULL, 0, 6, 0, MODE_SMA, PRICE_CLOSE, i)>iMA(NULL, 0, 2, 0, MODE_SMA, PRICE_CLOSE, i) 
       ) d7 = 0.5; 
       
        
        
        
      //up movement
       if(    
         iMA(NULL, 0, 4, 0, MODE_SMA, PRICE_CLOSE, i)<iMA(NULL, 0, 2, 0, MODE_SMA, PRICE_CLOSE, i)
       ) u1 = 1.0;
       
      if(    
         iMA(NULL, 0, 6, 0, MODE_SMA, PRICE_CLOSE, i)<iMA(NULL, 0, 4, 0, MODE_SMA, PRICE_CLOSE, i)
       ) u2 = 1.0;  
        
      if(  
         iMA(NULL, 0, 8, 0, MODE_SMA, PRICE_CLOSE, i)<iMA(NULL, 0, 6, 0, MODE_SMA, PRICE_CLOSE, i) 
       ) u3 = 1.0; 
        
      if(  
         iMA(NULL, 0, 10, 0, MODE_SMA, PRICE_CLOSE, i)<iMA(NULL, 0, 8, 0, MODE_SMA, PRICE_CLOSE, i) 
       ) u4 = 1.0; 
             
      
      // half point for 'two' averages removed, in order
      if(  false
        // iMA(NULL, 0, 10, 0, MODE_SMA, PRICE_CLOSE, i)<iMA(NULL, 0, 6, 0, MODE_SMA, PRICE_CLOSE, i) 
       ) u5 = 0.5; 
      
      if(  false
        // iMA(NULL, 0, 8, 0, MODE_SMA, PRICE_CLOSE, i)<iMA(NULL, 0, 4, 0, MODE_SMA, PRICE_CLOSE, i) 
       ) u6 = 0.5;
       
      if(  
         iMA(NULL, 0, 6, 0, MODE_SMA, PRICE_CLOSE, i)<iMA(NULL, 0, 2, 0, MODE_SMA, PRICE_CLOSE, i) 
       ) u7 = 0.5; 
      
           

      AtrBuffer[i]  = u1+u2+u3+u4+u5+u6+u7;
      
      TempBuffer[i] = d1+d2+d3+d4+d5+d6+d7;
      
      SumBuffer[i] = AtrBuffer[i] - TempBuffer[i];
      
      Gap[i] = 10000.0 * ( iMA(NULL, 0, 2, 0, MODE_SMA, PRICE_CLOSE, i) - iMA(NULL, 0, 10, 0, MODE_SMA, PRICE_CLOSE, i) );
      
   }
   
   
   for(i=0; i<limit; i++) {
   
      AvgSum[i] = iMAOnArray(SumBuffer, 0, AvgLen, 0, MODE_SMA, i);
      
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+


         
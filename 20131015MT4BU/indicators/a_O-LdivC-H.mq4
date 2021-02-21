//+------------------------------------------------------------------+
//|                                                a_O-LdivC-H.mq4   |
//|                                                           Aharon |
//|                                        http://www.anitani.com    |
//+-------------------------------------------------------------------

#property copyright "Copyright © 2011, Anitani Software Corp."
#property link      "http://www.anitani.com/trading"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 DodgerBlue
//---- input parameters
extern double threshold = 0.6;
//---- buffers
double Buffer[];
bool  upbar;
double top, bot, c, d, e;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- 1 additional buffer used for counting.
   IndicatorBuffers(1);
//---- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Buffer);
   //SetIndexBuffer(1,TempBuffer);
//---- name for DataWindow and indicator subwindow label
   short_name="(H-O)/(C-L)";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
//----
   SetIndexDrawBegin(0,0);
//----
   return(0);
  }
//+------------------------------------------------------------------+

int start()
  {
   int counted_bars = IndicatorCounted(),
       limit        = Bars-counted_bars;
   
   for(int i=0; i<limit; i++)   {
      if(Open[i+1]==Close[i+1]) continue;
      if(Open[i+1]<Close[i+1]) upbar = true;
      else upbar = false;
      
      if(upbar)   {
         top = High[i+1]- Close[i+1];
         bot = Open[i+1] - Low[i+1] ;
      }
      else  {
         top = High[i+1]- Open[i+1] ;
         bot = Close[i+1] - Low[i+1];
      }
      d = top-bot; //this is delta
      //if(bot==0.0) continue;
      c= d/(High[i+1]-Low[i+1]); //size of delta 'tail' compared to bar 
      
      if(MathAbs(c)>threshold) {
         if(c<0) Buffer[i+1] = 1.0; 
         if(c>0) Buffer[i+1] = -1.0; 
      }
      else Buffer[i+1] = 0.0; 
   }//close for loop
   
   return(0);
  }
//+------------------------------------------------------------------+















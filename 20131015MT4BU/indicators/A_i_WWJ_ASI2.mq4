//+------------------------------------------------------------------+
//|                                                 A_i_WWJ_ASI2.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
#property copyright "Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window

#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue
 
extern int    BarsBack  = 180;  //how far back to calculate

double h[], l[];

int    limit, i;
static int lastasi = -999999;  //this hold last asi value prev. to flat asi to compare and find top or bottom
static int count = 0;          //this counts number of bars asi remains flat, is used as flag to help detect tops or bottoms in case of flat asi curve


int init()  {
   IndicatorBuffers(2);
   string short_name;
   short_name = "A_i_WWJ_ASI2(" + BarsBack + ")";
   IndicatorShortName(short_name);

   SetIndexLabel(0, "h");
   SetIndexStyle(0,  DRAW_LINE);
   SetIndexBuffer(0, h);

   SetIndexLabel(1, "l");
   SetIndexStyle(1,  DRAW_LINE);
   SetIndexBuffer(1, l);
  
   return(0);
}

int start()  {
   //ArrayInitialize(si, EMPTY_VALUE);
   
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
   int asi0, asi1, asi2;
   bool nlv, nhv;
   for(i=BarsBack; i>=0; i--) {
      asi0 = iCustom(NULL, 0, "A_i_WWJ_ASI", BarsBack, 1, i);     //asign vars w/ asi values for last 3 bars 
      asi1 = iCustom(NULL, 0, "A_i_WWJ_ASI", BarsBack, 1, i+1);
      asi2 = iCustom(NULL, 0, "A_i_WWJ_ASI", BarsBack, 1, i+2);
      nlv = false;
      nhv = false;

      if(asi1>asi0 && asi1>asi2)   {
         h[i+1] = asi1;             //if conventional top
         nhv = true;  //new high value assigned
      }
      if(asi1<asi0 && asi1<asi2)   {
         l[i+1] = asi1;             //or bottom.
         nlv = true;  //new low value assigned
      }
                                                            //To detect top, or bottom in case of flat asi curve:
      if(asi1 == asi0)   {                                  //if asi is the same as prev. one, i.e. is flat
         count = count + 1;                                 //increment counter to count how many bars asi remains flat for 
         if(lastasi == -999999)lastasi = asi2;              //if lastasi not set, then set it to last asi value before 'flat'
      }
      if(count>0 && asi1 != asi0)  {                        //if flat asi is present, however, flat has just changed..
         if(asi0>asi1 && lastasi>asi1)   {
            l[i+1] = asi1;       //this is bottom
            nlv = true;  //new low value assigned
         }
         if(asi0<asi1 && lastasi<asi1)   {
            h[i+1] = asi1;       //this is top
            nhv = true;  //new high value assigned
         }
      }
      if(asi1 != asi0)   {                                  //if new asi value, reset count and lastasi var.s
         count = 0;
         lastasi = -999999;
      }
      if(!nlv) l[i+1]=l[i+2]; //if no new low value asigned, then reassign prev. value to new bar 
      if(!nhv) h[i+1]=h[i+2]; //if no new high value asigned, then reassign prev. value to new bar 
   }

   return(0);
}

int deinit()  {
   return(0);
}
//+------------------------------------------------------------------+
//|                                                A_Simple2_ind.mq4 |
//|                                                           Aharon |
//|                                           http://www.anitani.net |
//+------------------------------------------------------------------+
#property copyright "Aharon"
#property link      "http://www.anitani.net"

#property indicator_separate_window


#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red

//extern double lots  = 0.01;
//extern double minVel = 2.0;  //minimum velocity pips/per sec.
//extern int tp = 10;
//extern int sl = 25;

extern int l   =  3;    //number of tick for discrete velocity calc.
extern int len = 20;  //length of avg. vel.

int MAGICMA = 732, i, counter = 0, ac = 0, bc = 0, q = 0;
double ts, ct, a, b;
double b1, b2, b3, b4;
double t1, t2, t3, t4, temp;

double v = 0.0, av = 0.0, vtemp = 0.0, avtemp=0.0;
double AvgAskVel = 0.0;
double sumbid = 0.0, sumask = 0.0;


double TimestampTimeAskBid[4][200];   //1st dim. timestamps mSec. (index 0), 2nd current time (Sec.), 3nd Ask, 4th Bid
double vel[2][200];                   // 1st dim. is ask vel., 2nd is bid velocity
double accumvel[2][200];              // accumulated velocities of ask, and bid respectively on 1st and 2nd dims.
double AvgVel[2][200];                // average vel. ask, bid 

//indicator buffers
double s1[], s2[];
int init()   {
   ArrayInitialize(TimestampTimeAskBid, 0.0);
   ArrayInitialize(vel, 0.0);
   ArrayInitialize(accumvel, 0.0);
   ArrayInitialize(AvgVel, 0.0);
   //////////////////
   IndicatorBuffers(2);
   string short_name;
   short_name = "A_Simple_ind";
   IndicatorShortName(short_name);

   SetIndexLabel(0, "Accum. Bid Vel.");
   SetIndexStyle(0,  DRAW_LINE);
   SetIndexBuffer(0, s1);
   
   SetIndexLabel(1, "Accum. Ask Vel.");
   SetIndexStyle(1,  DRAW_LINE);
   SetIndexBuffer(1, s2);
   /////////////////
   return(0);
}


int start()   {
                                                      // update arrays for timestamp, ask, and bid prices
   ts = GetTickCount();                               //on price update, get timestamp (milliSec. since syst. start)-for delta calculation
   ct = TimeCurrent();                                //this is in seconds since 1/1/1970 (server)
   a  = Ask;
   b  = Bid;
                                                      // increment tick counters
   counter = counter + 1;                             // increment price update counter
   if(a!=TimestampTimeAskBid[2][0]) ac = ac + 1;      // if ask has changed, increment ask counter
   if(b!=TimestampTimeAskBid[3][0]) bc = bc + 1;      // if bid has changed, increment bid counter
   
   //Print(" ac=", ac, "  bc=",bc,"  counter= ", counter);
   
   for(i=200; i>=0; i--)   {                                        //shift stack 
      TimestampTimeAskBid[0][i] = TimestampTimeAskBid[0][i-1];      // timestamps mSec. (index 0)
      TimestampTimeAskBid[1][i] = TimestampTimeAskBid[1][i-1];      // this is in seconds since 1/1/1970 (server time)
      TimestampTimeAskBid[2][i] = TimestampTimeAskBid[2][i-1];
      TimestampTimeAskBid[3][i] = TimestampTimeAskBid[3][i-1];
      if(i==0)   {
          TimestampTimeAskBid[0][0] = ts;
          TimestampTimeAskBid[1][0] = ct;
          TimestampTimeAskBid[2][0] = a;
          TimestampTimeAskBid[3][0] = b;
      }
   }
   
   //calculate discrete velocity over arb. number of ticks, l
   //ask vel.
   if(ac>l)   {                                  // if minimum of, l, ask prices in buffer   
      for(i=200; i>=0; i--)   {                  // shift stack 
         vel[0][i] = vel[0][i-1];
         accumvel[0][i] = accumvel[0][i-1];
         if(i==0)   {                            // if reached all way down stack, put in latest vel. calculated
            vel[0][0] = ( (TimestampTimeAskBid[2][0]-TimestampTimeAskBid[2][l-1]) * MathPow(10,Digits)) /
                        ( MathMax((TimestampTimeAskBid[0][0]-TimestampTimeAskBid[0][l-1]), 1) / 1000);
            accumvel[0][0] = accumvel[0][1] + vel[0][0];
         }
      }
   }
   
   //Bid vel.
   if(bc>l)   {                                  // if minimum of, l, ask prices in buffer   
      for(i=200; i>=0; i--)   {                  // shift stack 
         vel[1][i] = vel[1][i-1];
         accumvel[1][i] = accumvel[1][i-1];
         if(i==0)   {                            // if reached all way down stack, put in latest vel. calculated
            vel[1][0] = ( (TimestampTimeAskBid[3][0]-TimestampTimeAskBid[3][l-1]) * MathPow(10,Digits)) /
                        ( MathMax((TimestampTimeAskBid[0][0]-TimestampTimeAskBid[0][l-1]), 1) / 1000);
            accumvel[1][0] = accumvel[1][1] + vel[1][0];
         }
      }
   }
   
   for(i=200; i>=0; i--)   {                  // shift stack   
      AvgVel[0][i] = AvgVel[0][i-1];
      AvgVel[1][i] = AvgVel[1][i-1];
      if(i==0)   {                            // if at bottom of stack
         sumask = 0.0;
         sumbid = 0.0;
         for(q = 0; q < len; q++)   {        // sum up over length
            sumask = sumask + vel[0][i];
            sumbid = sumbid + vel[1][i];
         }
         AvgVel[0][0] = sumask / len;         // get avg.
         AvgVel[1][0] = sumbid / len;
      }
   }
      
   for(i=0; i<200; i++)   {  //indicator buffer
      s1[i] = accumvel[0][i];
      s2[i] = accumvel[1][i];
   }
   
   Comment("Velocity in Pips/Sec (calculated over " + l + " ticks):\n" + 
           "Last Ask vel. " + vel[0][0] + "     Accum. ask vel. " + accumvel[0][0] + "\n" +
           "Last Bid vel. " + vel[1][0] + "     Accum. bid vel. " + accumvel[1][0] + "\n" +
           "AvgAskVel = " + AvgVel[0][0] + "        AvgBidVel = " + AvgVel[1][0]);

   return(0);
}







int deinit()  {
   
   return(0);
}




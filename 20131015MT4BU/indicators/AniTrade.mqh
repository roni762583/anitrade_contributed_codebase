//+------------------------------------------------------------------+
//|                                         AniTrade.mqh             |
//|                                Copyright © 2014, Aharon Zbaida   |
//|                      https://sites.google.com/site/aharonzbaida/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Aharon Zbaida"
#property link      "https://sites.google.com/site/aharonzbaida/"
//include
//function to build arrays of tops and bottoms features
//symbol, tf, barsBack, bool & featureTB[], double & featurePrices[], datetime & featureTimes[], arrays passed by reference

static bool TopsBotsFirstRun = true;


void TopsBots(string sym,int tf,int barsBack,int & featureTB[], double & featurePrices[], datetime & featureTimes[])
{
   for(int i=barsBack-1;i>0;i--)  {
      bool top = false;
      bool bot = false;
      double hi = iHigh(sym,tf,i);
      double lo = iLow(sym,tf, i);
      int arrayIndex;

      if(hi>iHigh(sym,tf,i+1) && hi>iHigh(sym,tf,i-1))  {
         top = true;
         arrayIndex = ArraySize(featureTB)-1;
            
         if(TopsBotsFirstRun)  {
            //Print("hi");
            TopsBotsFirstRun=false;
            setFeature(1,hi,iTime(sym,tf,i),featureTB,featurePrices,featureTimes);
         }//end if(TopsBotsFirstRun)
              
         else  { //not firstRun
            if(featureTB[arrayIndex]==1)  { //if prev. feature was top, did new feature beat it?
               if(hi>featurePrices[arrayIndex])  { //is this hi bigger?
                  //set this as feat instead of prev.
                  featurePrices[arrayIndex]=hi;
                  featureTimes[arrayIndex]=iTime(sym,tf,i);
               }
               //this hi did not beat prev. feature, just continue onward
            }//end if prev. feature is top
            else  { //prev. feature is bot, just set this feature
               setFeature(1,hi,iTime(sym,tf,i),featureTB,featurePrices,featureTimes);
            }
         }// end else  { //not firstRun
      }//if(iHigh(hi>sym,tf,i+1) && hi>iHigh(sym,tf,i-1)
        
        
      if(lo<iLow(sym,tf,i+1) && lo<iLow(sym,tf,i-1))  {//if bot...(here workut case of both top and bot.)
         bot = true;
         arrayIndex = ArraySize(featureTB)-1;//re-set cause don't know what assignments happened above in top
            
         if(TopsBotsFirstRun) {
            TopsBotsFirstRun=false;
            setFeature(-1,lo,iTime(sym,tf,i),featureTB,featurePrices,featureTimes); //if it's the first feature, set it
         }//if(TopsBotsFirstRun)
         
         else  { //not firstRun
            if(top && bot)  { //if both top and bot.
                
               if(featureTB[arrayIndex]==-1) { //if prev. feature was bot, did new feature beat it?
                  if(lo<featurePrices[arrayIndex]) { //if new feature is more extreme than prev.
                     //overwrite prev. feature
                     featurePrices[arrayIndex] = lo;
                     featureTimes[arrayIndex] = iTime(sym,tf,i);
                  }
                  else  {//prev. is bot, new is not more extreme, write new as opposite
                     setFeature(1,hi,iTime(sym,tf,i),featureTB,featurePrices,featureTimes);
                  }
               }  

               if(featureTB[arrayIndex]==1)  {
                  if(hi>featurePrices[arrayIndex])  { //if prev. feature was top, did new feature beat it?
                     //overwrite prev. feature
                     featurePrices[arrayIndex] = hi;
                     featureTimes[arrayIndex] = iTime(sym,tf,i);
                  }
                  else  {
                     setFeature(-1,lo,iTime(sym,tf,i),featureTB,featurePrices,featureTimes);
                  }
               }
            }//end if both top and bot.
                   
            else  { //this is just a bot, not double
               if(featureTB[arrayIndex]==1)  { //if prev. was top, set this as new bot.
                  setFeature(-1,lo,iTime(sym,tf,i),featureTB,featurePrices,featureTimes);
               }
               else  { //prev. feature must have been a bot since not top
                  if(featureTB[arrayIndex]==-1 && lo<featurePrices[arrayIndex]) { //made explicit
                     //if this lo is lower than prev. feature lo, overwrite prev. feature
                     featurePrices[arrayIndex]=lo;
                     featureTimes[arrayIndex]=iTime(sym, tf, i);
                  }
               }
            }//end else this is just bot.
         }//end else //not first run
      }//if(lo<iLow(sym,tf,i+1) && lo<iLow(sym,tf,i-1))
   }//for i
}//TopsBots


void setFeature(int feature,double price,datetime time,int & featureTB[],double & featurePrices[],datetime & featureTimes[])
{
   //Print("hello from set feature, array size = ",ArraySize(featureTB));
   int newSize = ArraySize(featureTB) + 1;
   ArrayResize(featureTB,newSize,0); //use reserve=0 because can't use ArrayBsearch on unsorted array, and need to retain order
   ArrayResize(featurePrices,newSize,0);
   ArrayResize(featureTimes,newSize,0);
   featureTB[newSize-1] = feature;
   featurePrices[newSize-1] = price;
   featureTimes[newSize-1]=time;
   //Print("hello Again from set feature, array size = ",ArraySize(featureTB));
}
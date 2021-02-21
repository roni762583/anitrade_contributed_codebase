
//                 Aharon_Test.mq4 

double s[7][2];
    

int init()
{
    
    for(int x = 0; x<=6; x++) {
       
       for(int y =0; y<=1; y++) {
          s[x,y]=x*y;
       }
    }
    
    for(x = 0; x<=6; x++) {
       
       for(y =0; y<=1; y++)     {
         Print("x= ",x,"   y= ",y,"   s[x,y]= ", s[x,y]);
       }
       
    }
    
    Print("farmam(s) returned ", farmam(s));
    
    return(0);
}
  
int start() {

   return(0);
}


//function farmam
double farmam(double sig[][])  {
   if(ArrayDimension(sig)!=2) return(0);
   
   double sum[2];                         //declaring array of dim = 1 & of 2 elements
   int size = ArrayRange(sig, 0);
   
   for(int x = 0; x<size; x++) {
       for(int y =0; y<=1; y++) {
          sum[0] = 2.2;
          sum[1] = 3.3;//sig[x,y];     //this line will be replaced by actual firma/arma calculated values in the return array
       }
    }
    
    
   return(sum);
}


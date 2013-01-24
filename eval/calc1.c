#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

/*
==> ../submissions.joined/DUTHlrgA <==
200 3.1131864.J0J3TR2N0RG3S14J0YZZGLYEO0TKDI5BA 1 0.998028 DUTHlrgA  100 1
*/

/*  R numbers
200 2543.52
201 2366.28
202 4615.27
203 4944.23
204 6361.83
205 67438.43
206 929.09
207 20929.17
*/

int n, b, top, batch, rel, oldtop, Rel[5][3];
double score, rels, estrel, bestF, Rels[1000000], Estrel[1000000];

stats(){
   int i,j,k;
   rels = 0;
   for (i=1;i<=4;i++) {
     // For all the 4 different batches
      if (Rel[i][0] || Rel[i][1]) {
        // Take all documents that are either relevant (1) or...kinda relevant? (0)
        // And calculate some weird fucking score...
        // x = number of relevant (1) docs in this batch for this topic
        // y = number of irrelevant (0) docs in this batch for this topci
        // z = number of undecided (-1) docs in this batch for this topic
        // x / (y + x) * (z + y + x)
        // This somehow appears to be the 
        //  numer of OR relevance scores
        // calculated and stored in Rels after each doc is processed.
        //
        // Confirmed.  This is SOMEHOW the number of relevant documents...
        rels += (double) Rel[i][1] / (Rel[i][0] + Rel[i][1]) * (Rel[i][-1] + Rel[i][0] + Rel[i][1]);
      }
   }
}

double errcalc(double a, double b) {
   if (b > a) return errcalc(b,a);
   return 100 - 100 * (a - b)/a;
}

doit(){
   stats();
   if (oldtop) {
      int i,j,bn=0,bnest=0;
      double P,R,F,estP,estR,estF,bF=0,bestF=0, bFest=0;
      printf("==== Topic %d ====\n",oldtop);
      printf("Documents returned     Recall   Precision   F1   Nonrelevant    Estmated Rel   Estimated Non\n");
      for (i=1;i<=n;i++) {
         P = Rels[i]/i; // Precision
         R = Rels[i]/Rels[n]; // Recall
         F = 2/(1/P+1/R);
         estP = Estrel[i]/i;
         estR = Estrel[i]/Estrel[n];
         estF = 2/(1/estP+1/estR);
         if (F > bF) {
            bF = F;
            bn = i;
         }
         if (estF > bestF) {
            bestF = estF;
            bFest = F;
            bnest = i;
         }
         if (i == 10 || i == 100 || i == 1000 || i == 100000 || i == 20 || i == 200 || i == 2000 || i == 20000
                || i == 200000|| i == 500000 || i == 50 || i == 500 || i == 5000 || i == 50000 || i == n) {
            printf("%7d (%5.3lf) %7.0lf  (%5.3lf)  (%5.3lf)  (%5.3lf) %7.0lf (%5.3lf) %7.0lf (%5.3lf) %7.0lf (%5.3lf)\n",
                 i,(double)i/n,
                 Rels[i],R,
                 P,F,
                 i-Rels[i],(i-Rels[i])/(n-Rels[n]),
                 Estrel[i],estR,
                 i-Estrel[i],(i-Estrel[i])/(n-Estrel[n]));
         }
      }
      //printf("%d Rel %0.0lf estRel %0.0lf acc %0.1lf%% possible F1 %0.1lf%% estimated %0.1lf%% actual F1 %0.1lf%% Ferr %0.1lf%% %d %d %0.1lf%%\n", oldtop,Rels[n],Estrel[n],errcalc(Rels[n],Estrel[n]),100*bF,100*bestF,100*bFest,errcalc(bestF,bFest),bn,bnest,errcalc(bn,bnest));
   }
   bestF = 0;
   estrel = 0;
   n = 0;
   oldtop = top;
   memset(Rel,0,sizeof(Rel));
}

main(){
   while (4 == scanf("%d%*s%*s%lf%*s%d%d",&top,&score,&batch,&rel)) {
      if (top != oldtop) doit();
      if      (batch == 100) b = 1;
      else if (batch == 1000) b = 2;
      else if (batch == 10000) b = 3;
      else if (batch == 1000000) b = 4;
      else printf("oops\n");
      Rel[b][rel]++;
      n++;
      estrel += score;
      Estrel[n] = estrel;
      stats();
      Rels[n] = rels;
      //double F = 100.0*2/(R[top-200]/rels+(double)n/rels);
      //printf("%d n %d estrel %0.1lf rel %0.1lf prec %0.3lf recall %0.3lf F %0.3lf\n",
             //top,n,estrel,rels,100.0*rels/n,100.0*rels/R[top-200],F);
      //if (F > bestF) bestF = F;
      //printf("%d %0.6lf %d %d\n",top,score,batch,rel);
   }
   doit();
}

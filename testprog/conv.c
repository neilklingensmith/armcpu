



// helper macros to get the min and max of two numbers
#define MIN(X, Y) (((X) < (Y)) ? (X) : (Y))
#define MAX(X, Y) (((X) < (Y)) ? (Y) : (X))


unsigned int convolve(float *out, float *a, float *b, unsigned int na, unsigned int nb) {
  unsigned int i,j,a_start,b_start,b_end;

  int nconv = na + nb - 1;

  for (i = 0; i < nconv; i++)
  {
    b_start = MAX(0,i-na+1);
    b_end   = MIN(i+1,nb);
    a_start = MIN(i,na-1);
    for(j = b_start; j < b_end; j++)
    {
      out[i] += a[a_start--]*b[j];
    }
  }
  return  nconv;
}

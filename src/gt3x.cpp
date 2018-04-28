#include <Rcpp.h>

using namespace Rcpp;

//' Convert a vector of raw bytes to yxz g values
//'
//' Raw activity samples packed into 12-bit values in YXZ order.
//'
//' @param bytes A RawVector
//' @param scale Scale factor to return acceleration in g
//' @return A NumericVector of g values in yxz order
//'
// [[Rcpp::export]]
NumericVector read_activityC(RawVector bytes, double scale) {
  NumericVector res;

  int n = bytes.size() -1;
  bool alt = true;
  uint16_t data;

  for (int i=0; i < n; ++i) {
    if (alt) {
      data = (((bytes[i] << 8) | ((bytes[i+1]))) >> 4);
    } else {
      data = (((bytes[i] << 8) | ((bytes[i+1]))) & 0xFFF);
      i++;
    }
    alt = !alt;

    if (data > 0x7FF) data |= 0xF000;

    res.push_back(round(((int16_t)data) / scale * 1000.0f) / 1000.0f);
  }

  return res;
}

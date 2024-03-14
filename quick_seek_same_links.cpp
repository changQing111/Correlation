#include <Rcpp.h>
//#include <C:/Users/lenovo/AppData/Local/R/win-library/4.2/RcppParallel/include/RcppParallel.h>
#include <string>
#include <algorithm>
#include <unordered_set>
#include <set>
using namespace Rcpp;

// This is a simple example of exporting a C++ function to R. You can
// source this function into an R session using the Rcpp::sourceCpp 
// function (or via the Source button on the editor toolbar). Learn
// more about Rcpp at:
//
//   http://www.rcpp.org/
//   http://adv-r.had.co.nz/Rcpp.html
//   http://gallery.rcpp.org/
//



// [[Rcpp::export]]
double my_jaccard(const CharacterVector& vec1, const CharacterVector& vec2) { 
  std::vector<std::string> vec_1 = as<std::vector<std::string>>(vec1), vec_2 = as<std::vector<std::string>>(vec2);
  std::sort(vec_1.begin(), vec_1.end());
  std::sort(vec_2.begin(), vec_2.end());
  // intersection
  std::vector<std::string> intersect_vec;  
  std::set_intersection(vec_1.begin(), vec_1.end(), vec_2.begin(), vec_2.end(), std::back_inserter(intersect_vec));
  size_t intersect_size= intersect_vec.size();
  // union
  size_t union_size = vec_1.size() + vec_2.size() - intersect_size;
  double jaccard = 1.0*intersect_vec.size()/union_size;
  return jaccard;  
}  

// [[Rcpp::export]]
void seek_same_links(const List& kmer_li1, const List& kmer_li2, int len1, int len2, 
                     NumericVector& index1, NumericVector& index2, double simil=0.85) {
  int n = 0;
  for(int i=0; i < len1; i++) {
    for(int j=0; j < len2; j++) {
      double res = my_jaccard(kmer_li1[i], kmer_li2[j]);
      if(res > simil) {
        n++;
        index1[n] = i+1;
        index2[n] = j+1;
      }
    }
  }
}

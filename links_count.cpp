#include <stdio.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <unordered_map>

using namespace std;

void read_corr_pvalue_df(const string& file_path, const string name, 
                         unordered_map<string, string>& links_n, int n);
vector<string> split_str(const string& str, const char sep);
string sort_links(const string& from, const string& to, const char sep);
void traver_map(unordered_map<string, string>& links_n, const string& outname);
string copy_str(const string source);

int main(int argc, char* argv[]) 
{   
    if(argc < 4) {
        fprintf(stderr, "Usage: %s file_path1,filepath2 name1,name2 out_name\n", argv[0]);
        exit(-1);
    }
    unordered_map<string, string> links_num;
    vector<string> file_path_li = split_str(argv[1], ',');
    vector<string> name_li = split_str(argv[2], ',');
    string out_name = argv[3];
    read_corr_pvalue_df(file_path_li[0], name_li[0], links_num, 1);
    for(int i = 1; i < name_li.size(); i++) {
        read_corr_pvalue_df(file_path_li[i], name_li[i], links_num, i+1);
    }
    traver_map(links_num, out_name);

    return 0;
}

string copy_str(const string source)
{
    string target(source.size(), '0');
    source.copy(target.data(), source.size());
    return target;
}

void read_corr_pvalue_df(const string& file_path, const string name, 
                        unordered_map<string, string>& links_n, int n)
{   
    // read file
    ifstream corr_pvalue_f(file_path);
    std::string line;
    getline(corr_pvalue_f, line);  // skip header
    // write file
    string out_name = copy_str(name) + "_links.txt";
    ofstream write_f(out_name);

    if(n == 1) {
        while(getline(corr_pvalue_f, line)) {
            vector<string> str_li = split_str(line, ',');
            string links = sort_links(str_li[0], str_li[1], ':');
            write_f << links << '\n';  // write to file
            string project_n = copy_str(name);
            links_n[links] = project_n;
            //links_n[links] = 1;
        }
    }
    else {
        while(getline(corr_pvalue_f, line)) {
            vector<string> str_li = split_str(line, ',');
            string links = sort_links(str_li[0], str_li[1], ':');
            write_f << links << '\n';  // write to file
            auto it = links_n.find(links);
            if(it != links_n.end()) {
                //links_n[links]++;
                string tmp = copy_str(name);
                links_n[links] = links_n[links] + ',' + tmp;
            }
            else {
                //links_n[links] = 1;
                string project_n = copy_str(name);
                links_n[links] = project_n;
            }       
        }
    }
    write_f.close();
}

vector<string> split_str(const string& str, const char sep=',')
{
    vector<string> tokens;  
    string token;
    std::istringstream tokenStream(str);
    while(getline(tokenStream, token, sep)) {
        tokens.push_back(token);
    }
    return tokens;
}

string sort_links(const string& from, const string& to, const char sep=':')
{   
    string link;
    if(from < to) {
        link = from + sep + to;
    } else {link = to + sep + from;}
    return link;
}

void traver_map(unordered_map<string, string>& links_n, const string& outname)
{   
    ofstream write_f(outname);
    for(unordered_map<string, string>::iterator it = links_n.begin(); it!=links_n.end(); ++it) {
        vector<string> name_li = split_str(it->second, ',');
        write_f << it->first << '\t' << it->second << '\t' << name_li.size() << '\n';
    }
    write_f.close();
}

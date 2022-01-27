using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace DeskCollWebService.Models
{
    public class DeskCollParam
    {
        //public int id { get; set; }
        public string account_no { get; set; }
        public DateTime collection_date { get; set; }
        public string cust_name { get; set; }
        public string result_code { get; set; }
        public string action_code { get; set; }
        public string remark { get; set; }
        //public string asal_action { get; set; }
        //public DateTime cre_date { get; set; }
        public string cre_by { get; set; }
        public string cre_ip_address { get; set; }
        //public DateTime mod_date { get; set; }
        public string mod_by { get; set; }
        public string mod_ip_address { get; set; }
        public DateTime promise_date { get; set; }
        public int period { get; set; }
        //public string c_code { get; set; }
        public string hashing { get; set; }
    }
}
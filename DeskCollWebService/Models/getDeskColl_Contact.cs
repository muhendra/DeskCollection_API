using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace DeskCollWebService.Models
{
    public class getDeskColl_Contact
    {
        public List<dataTask> data { get; set; }

        public static getDeskColl_Contact GetResult()
        {
            getDeskColl_Contact res = new getDeskColl_Contact();

            string ssql = "exec [dbo].[getDeskCollection_Contact]";
            DataTable resDT = new DataTable();
            string connString = ConfigurationManager.ConnectionStrings["SqlConnectionString"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(ssql ,conn))

                try
                {
                    SqlCommand sqlCommand = new SqlCommand(ssql);
                    sqlCommand.CommandType = CommandType.Text;
                    sqlCommand.Connection = conn;
                    conn.Open();
                    cmd.ExecuteNonQuery();
                    SqlDataReader reader = sqlCommand.ExecuteReader();
                    
                    resDT.Load(reader);
                    conn.Close();
                        
                        var listDtTask = new List<dataTask>();

                        foreach (DataRow dr in resDT.Rows)
                        {
                            dataTask MdlTask = new dataTask();
                            MdlTask.contract_no = dr["contract_no"].ToString();
                            MdlTask.name = dr["name"].ToString();
                            MdlTask.contract_person = dr["contact_person"].ToString();
                            MdlTask.address = dr["address"].ToString();
                            MdlTask.branch_name = dr["branch_name"].ToString();
                            MdlTask.marketing_name = dr["marketing_name"].ToString();
                            MdlTask.phone1 = dr["phone1"].ToString();
                            MdlTask.phone2 = dr["phone2"].ToString();
                            MdlTask.phone3 = dr["phone3"].ToString();
                            MdlTask.phone4 = dr["phone4"].ToString();
                            MdlTask.overdue = dr["overdue"].ToString();
                            MdlTask.installmentNumber = dr["installmentNumber"].ToString();
                            MdlTask.total_installmentNumber = dr["total_installmentNumber"].ToString();
                            MdlTask.dueDate_Installment = dr["duedate_installment"].ToString();
                            MdlTask.payment_methode = dr["payment_methode"].ToString();
                            MdlTask.description_assets = dr["description_assets"].ToString();
                            MdlTask.customer_code = dr["customer_code"].ToString();
                            MdlTask.installmentNumber = dr["installment_amount"].ToString();
                            MdlTask.penalty = dr["pinalty"].ToString();
                            MdlTask.total_amount = dr["total_amount"].ToString();
                            MdlTask.osar = dr["osar"].ToString();
                            MdlTask.lastpaid_amount = dr["lastpaid_amount"].ToString();
                            MdlTask.lastpaid_duedate = dr["lastpaid_duedate"].ToString();
                            MdlTask.lastpaid_tenor = dr["lastpaid_tenor"].ToString();
                            MdlTask.lastpaid_paymentdate = dr["lastpaid_paydate"].ToString();
                            MdlTask.product = dr["product"].ToString();
                            MdlTask.flag_dedicated = dr["flag_dedicated"].ToString();
                            
                            listDtTask.Add(MdlTask);
                            
                    }
                    
                    //final add to header
                    res.data = listDtTask;

                    string jsonRes = JsonConvert.SerializeObject(res);
                }

                catch (SqlException ex)
                {

                }
            
            return res;
        }
    }

    public class dataTask
    {
        public string contract_no { get; set; }
        public string name { get; set; }
        public string contract_person { get; set; }
        public string address { get; set; }
        public string branch_name { get; set; }
        public string marketing_name { get; set; }
        public string phone1 { get; set; }
        public string phone2 { get; set; }
        public string phone3 { get; set; }
        public string phone4 { get; set; }
        public string overdue { get; set; }
        public string installmentNumber { get; set; }
        public string total_installmentNumber { get; set; }
        public string dueDate_Installment { get; set; }
        public string payment_methode { get; set; }
        public string description_assets { get; set; }
        public string customer_code { get; set; }
        public string installment_amount { get; set; }
        public string penalty { get; set; }
        public string total_amount { get; set; }
        public string osar { get; set; }
        public string lastpaid_amount { get; set; }
        public string lastpaid_duedate { get; set; }
        public string lastpaid_tenor { get; set; }
        public string lastpaid_paymentdate { get; set; }
        public string product {get; set;}
        public string flag_dedicated {get; set;}
    }
}
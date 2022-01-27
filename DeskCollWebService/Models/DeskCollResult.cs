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
    public class DeskCollResult
    {
        public string respon_code {get; set;}
        public string respon_mess { get; set; }

        public static DeskCollResult GetResult(DeskCollParam x)
        {
            DeskCollResult res = new DeskCollResult();

            string jsonPost = JsonConvert.SerializeObject(x);

            try
            {
                string connString = ConfigurationManager.ConnectionStrings["SqlConnectionString"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connString))
                using (SqlCommand cmd = new SqlCommand("[dbo].[sp_account_collection_insert]", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    // set up the parameters
                    cmd.Parameters.Add("@p_id", SqlDbType.Int).Direction = ParameterDirection.Output;
                    cmd.Parameters.Add("@p_account_no", SqlDbType.VarChar, 25);
                    cmd.Parameters.Add("@p_collection_date", SqlDbType.DateTime);
                    cmd.Parameters.Add("@p_cust_name", SqlDbType.VarChar, 50);
                    cmd.Parameters.Add("@p_result_code", SqlDbType.VarChar, 10);
                    cmd.Parameters.Add("@p_action_code", SqlDbType.VarChar, 10);
                    cmd.Parameters.Add("@p_remark", SqlDbType.NVarChar, 255);
                    cmd.Parameters.Add("@p_asal_action", SqlDbType.NVarChar, 10);
                    cmd.Parameters.Add("@p_cre_date", SqlDbType.DateTime);
                    cmd.Parameters.Add("@p_cre_by", SqlDbType.NVarChar, 25);
                    cmd.Parameters.Add("@p_cre_ip_address", SqlDbType.NVarChar, 25);
                    cmd.Parameters.Add("@p_mod_date", SqlDbType.DateTime);
                    cmd.Parameters.Add("@p_mod_by", SqlDbType.NVarChar, 25);
                    cmd.Parameters.Add("@p_mod_ip_address", SqlDbType.NVarChar, 25);
                    cmd.Parameters.Add("@p_promise_date", SqlDbType.DateTime);
                    cmd.Parameters.Add("@p_period", SqlDbType.Int);
                    cmd.Parameters.Add("@p_c_code", SqlDbType.NVarChar, 6);

                    // set parameter values
                    cmd.Parameters["@p_id"].Value = 0;
                    cmd.Parameters["@p_account_no"].Value = x.account_no;
                    cmd.Parameters["@p_collection_date"].Value = x.collection_date;
                    cmd.Parameters["@p_cust_name"].Value = x.cust_name;
                    cmd.Parameters["@p_result_code"].Value = x.result_code;
                    cmd.Parameters["@p_action_code"].Value = x.action_code;
                    cmd.Parameters["@p_remark"].Value = x.remark;
                    cmd.Parameters["@p_asal_action"].Value = "Desk Coll ";
                    cmd.Parameters["@p_cre_date"].Value = DateTime.Now;
                    cmd.Parameters["@p_cre_by"].Value = x.cre_by;
                    cmd.Parameters["@p_cre_ip_address"].Value = x.cre_ip_address;
                    cmd.Parameters["@p_mod_date"].Value = DateTime.Now;
                    cmd.Parameters["@p_mod_by"].Value = x.mod_by;
                    cmd.Parameters["@p_mod_ip_address"].Value = x.mod_ip_address;
                    cmd.Parameters["@p_promise_date"].Value = x.promise_date;
                    cmd.Parameters["@p_period"].Value = x.period;
                    cmd.Parameters["@p_c_code"].Value = "0000";

                    // open connection and execute stored procedure
                    conn.Open();
                    cmd.ExecuteNonQuery();

                    // read output value
                    //res.id = x.id;
                    res.respon_code = "00";
                    res.respon_mess = "Sukses Memasukan Data Dengan Account No : " + x.account_no;

                    conn.Close();
                }

                string jsonRes = JsonConvert.SerializeObject(res);
            }
            catch (SqlException ex)
            {
                res.respon_code = "90";
                res.respon_mess = "ERROR: Account No " + x.account_no + " does not exist";
            }

            return res;
        }
    }
}
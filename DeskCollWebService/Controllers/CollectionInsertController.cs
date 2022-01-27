using DeskCollWebService.Models;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
namespace DeskCollWebService.Controllers
{
    public class CollectionInsertController : ApiController
    {
        private static readonly log4net.ILog log = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        [HttpPost]
        public HttpResponseMessage Post([FromBody] DeskCollParam values)
        {
            log.Info("REQUEST Collection Insert PARAMETER | " + Helper.PrintObject(values));
            DeskCollParam res = values;
            
            string hashKey = ConfigurationManager.AppSettings["HashKey"];

            if (Hash.Authentication(res.hashing, res.account_no + hashKey))
            {
                DeskCollResult r = DeskCollResult.GetResult(res);
                log.Info("RESULT Collection Insert PARAMETER | " + Helper.PrintObject(r));
                return Request.CreateResponse(HttpStatusCode.OK, r);
            }

            else
            {
                DeskCollResult pay = new DeskCollResult();
                pay.respon_code = "91";
                pay.respon_mess = "Invalid Token";
                log.Info("RESULT Collection Insert PARAMETER | " + Helper.PrintObject(pay));

                return Request.CreateResponse(HttpStatusCode.Forbidden, pay);
            }
        }

        public string Get()
        {
            return "Welcome To Web API MNC GUI";
        }
    }
}
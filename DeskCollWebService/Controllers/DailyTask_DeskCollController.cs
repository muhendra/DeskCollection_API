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
    public class DailyTask_DeskCollController : ApiController
    {
        private static readonly log4net.ILog log = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        public HttpResponseMessage Get()
        {
            getDeskColl_Contact r = getDeskColl_Contact.GetResult();
            log.Info("RESULT Task MNCGUI | " + Helper.PrintObject(r));
            return Request.CreateResponse(HttpStatusCode.OK, r);
        }
    }
}
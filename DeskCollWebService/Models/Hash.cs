using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;

namespace DeskCollWebService.Models
{
    public class Hash
    {
        public static bool Authentication(string hashValue, string stringCompare)
        {
            using (SHA256 sha256Hash = SHA256.Create())
            {
                //From String to byte array
                byte[] sourceBytes = Encoding.UTF8.GetBytes(stringCompare);
                byte[] hashBytes = sha256Hash.ComputeHash(sourceBytes);
                string hash = BitConverter.ToString(hashBytes).Replace("-", String.Empty);

                if (String.Equals(hash, hashValue, StringComparison.OrdinalIgnoreCase))
                {
                    return true;
                }

                else
                {
                    return false;
                }

            }
        }
    }
}
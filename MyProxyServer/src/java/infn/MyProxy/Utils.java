/**************************************************************************
Copyright (c) 2011-2015: 
Istituto Nazionale di Fisica Nucleare (INFN), Italy
Consorzio COMETA (COMETA), Italy

See http://www.infn.it and http://www.consorzio-cometa.it for details 
on the copyright holders.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Author(s): Giuseppe La Rocca (INFN), Salvatore Monforte (INFN)
****************************************************************************/
package infn.MyProxy;

import java.io.File;
import java.io.FileInputStream;

class Utils 
{
  public static String rtrim(String s, char ch) 
  {
    return s.lastIndexOf(ch) > 0 ? s.substring(0, s.lastIndexOf(ch)) : s;
  }

  public static String unquote(String str) 
  {
    return unquote(str, '\"');
  }

  public static String unquote(String str, char c) 
  {
    int length = str == null ? -1 : str.length();
    if (str == null || length == 0) return str;    

    if (length > 1 && str.charAt(0) == c && str.charAt(length - 1) == c)
      str = str.substring(1, length - 1);    

    return str;
  }

  public static String readFileAsString(String filePath) 
          throws java.io.IOException 
  {
    byte[] buffer = new byte[(int) new File(filePath).length()];
    FileInputStream f = new FileInputStream(filePath);
    f.read(buffer);
    
    return new String(buffer);
  }
}
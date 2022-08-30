using System;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Net;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Text.RegularExpressions;
using System.Xml;
using System.Xml.XPath;
using System.Linq;
using System.Xml;
using System.Xml.Linq;

namespace OUC{
	public class NestedNav{

		private int _nestLevel = 0;
		private int _nestLimit = -1;//no limit
		private string _html = "";
		private string _currentDirectory = "";
		private string _navFileName = "_nav.inc";
		private string _matchLIRegex = @"<li[^>]*?>[\s]*?<a[^>]*?>[\s\S]*?<\/a>[\s]*?<\/li>";
		private string _matchSectionLIRegex = @"<li[^>]*?>[\s]*?<a[^>]*?href=""(\/[^""]*?\/)(default.aspx)?""[^>]*?>([\s\S]*?)<\/a>[\s]*?<\/li>";
        private List<String> _processedDirs = new List<String>();

        public NestedNav(){}

		public NestedNav(int nestLimit){
			_nestLimit = nestLimit;
		}

		public string GetNav(string navFile){

			_currentDirectory = navFile.Replace(_navFileName, "");

			string html = "<ul id=\"explore-navigation\">";

			html += ProcessNavFile(navFile);

			html += "</ul>";

			return html;
		}

		private string ProcessNavFile(string navFile){

			string filePath = HttpContext.Current.Server.MapPath(navFile);
			string fileContent = "";

			_nestLevel++;

			try{
				using(StreamReader streamReader = new StreamReader(filePath)){
					fileContent = streamReader.ReadToEnd();
				}
			}
			catch(Exception e){
				return "!<!--" + e.Message + "-->";
			}

			// remove comments so commented links will not be matched/displayed
			string _matchCommentsRegex = @"<!--[\s\S]*?-->";
			fileContent = Regex.Replace(fileContent, _matchCommentsRegex, "");

			Regex regex = new Regex(_matchLIRegex);
			MatchEvaluator matchLI = new MatchEvaluator(MatchLI);

			regex.Replace(fileContent, matchLI);

			_nestLevel--;

			return _html;
		}

		private string MatchLI(Match match){

			string li = match.Value;

			Regex regex = new Regex(_matchSectionLIRegex);
			MatchEvaluator matchSectionLI = new MatchEvaluator(MatchSectionLI);

			if(regex.IsMatch(li)){
				regex.Replace(li, matchSectionLI);
			}
			else{
				_html += li;
			}

			return "";
		}

		private string MatchSectionLI(Match match){

			string li = match.Value;
			string href = match.Groups[1].Value;
			string page = match.Groups[2].Value;
			string title = match.Groups[3].Value;

			string filePath = href + _navFileName;
			string serverFilePath = HttpContext.Current.Server.MapPath(filePath);
			bool processNavFile = true;

			//check if file exists
			if(File.Exists(serverFilePath)){
				string fileContent = "";

				try{
					using(StreamReader streamReader = new StreamReader(serverFilePath)){
						fileContent = streamReader.ReadToEnd();
					}
				}
				catch(Exception e){
					return "!<!--" + e.Message + "-->";
				}

				//make sure the file contains at least one <li>
				//so an empty <ul> is not generated
				Regex regex = new Regex(_matchLIRegex);
				if(!regex.IsMatch(fileContent)){
					processNavFile = false;
				}
			}
			else{
				processNavFile = false;
			}

			//don't process the current sections default page
			//in cases where it's present in the nav file
			if(href == _currentDirectory){
				processNavFile = false;
			}

			//so users can override nesting of particular sections
			if(li.Contains("class=\"ou-no-subnav\"")){
				processNavFile = false;
			}

			//stop at the specified nesting level
			if(_nestLevel == _nestLimit){
				processNavFile = false;
			}

            if (_processedDirs.Contains(filePath))
            {
                processNavFile = false;
            }

            //process the sub section nav file
            if (processNavFile){
				_html += String.Format("<li><a href=\"{0}{1}\">{2}</a><ul>",
					href, page, title);

				_currentDirectory = href;

                _processedDirs.Add(filePath);

                ProcessNavFile(filePath);

				_html += "</ul></li>";
			}
			else{
				//write out the section link with no processing
				_html += li;
			}

			return "";
		}
	}
}

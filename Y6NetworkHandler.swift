//
//  Y6NetworkHandler.swift
//
//
//  Created by Ysix on 04/03/2015.
//  Copyright (c) 2015 ysixapps. All rights reserved.
//

import Foundation

enum RequestMethod {
    case POST
    case GET
}

class Y6NetworkHandler
{
    func sendRequest(url: String, completionClosure: (status: Int, response:AnyObject) -> (), method:RequestMethod, parameters:Dictionary<String,String>)
    {
        var urlString = url;
        
        if countElements(parameters) > 0 && method == RequestMethod.GET
        {
            var parametersUrl = ""
            
            for (key, value) in parameters
            {
                if (countElements(parametersUrl) != 0)
                {
                    parametersUrl += "&"
                }
                parametersUrl += "\(key)=\(value)"
            }
            
            urlString += "?\(parametersUrl)"
        }
        
        var url: NSURL = NSURL(string: urlString)!

        
        var request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
        
        switch method
        {
        case .POST:
            request.HTTPMethod = "POST"
        default:
            break;
        }
        
        
        if countElements(parameters) > 0 && method != RequestMethod.GET
        {
            var err: NSError?
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: nil, error: &err)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		}
		
		request.addValue("application/json", forHTTPHeaderField: "Accept")

		println("call \(url) with parameters : \(parameters)")
        
		NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue())
			{
				(response, data, error) in

				if error == nil
				{
					if let HTTPResponse = response as? NSHTTPURLResponse
					{
						let statusCode = HTTPResponse.statusCode
						if statusCode == 200
						{
							// Yes, Do something.
							if ((HTTPResponse.allHeaderFields["Content-Type"] as String).rangeOfString("application/json", options: nil) != nil)
							{
								var err: NSError?
								let JSON: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &err)

								println("got : \(JSON)")

								completionClosure(status: statusCode, response: JSON!)
							}
							else
							{
								println("Wrong Content-Type : " + (HTTPResponse.allHeaderFields["Content-Type"] as String))
							}
						}
						else
						{
							println("An error happend status : \(statusCode)")
						}

					}
				}
				else
				{
					println("An error happend error description : \(error.localizedDescription) - \(error.localizedFailureReason)\n may can be solve by : \(error.localizedRecoveryOptions) - \(error.localizedRecoverySuggestion)")
				}
		}
	}

}
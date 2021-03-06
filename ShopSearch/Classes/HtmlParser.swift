//
//  HtmlParser.swift
//  ShopSearch
//
//  Created by Ricardo Koch on 4/2/16.
//  Copyright © 2016 Ricardo Koch. All rights reserved.
//

import Foundation
import hpple

protocol HtmlParserDelegate: NSObjectProtocol {
    func parserDidFinishWorking(_ objects:[AnyObject])
}

class HtmlParser: NSObject {
    
    enum ParserType: Int {
        case type1
        case type2
        case type3
		case type4
        case noParserAvailable
        
        static let all = [type1, type2, type3, type4, noParserAvailable]
    }
    
    var parserType = ParserType.type1

    var htmlData:Data!
    weak var delegate: HtmlParserDelegate?
    
    func parseWithXPath(_ xPathQuery:String, onData data:Data) -> [TFHppleElement] {
        
        self.htmlData = data as Data!
        let parser = TFHpple(htmlData: self.htmlData)
        let elements = parser?.search(withXPathQuery: xPathQuery)
        return elements as? [TFHppleElement] ?? []
    }
    
    func parseMainCategory(_ data: Data) -> GoogleCategory? {
        
        var catCode: String?
        while self.parserType != ParserType.noParserAvailable && catCode == nil {
            
            let sideMenuLink:TFHppleElement?
            switch self.parserType {
            case .type1:
                //search category
                sideMenuLink = self.parseWithXPath("//html//a[@class=\"sr__bc-link\"]", onData: data).first
                break
            case .type2:
                //search category
                sideMenuLink = self.parseWithXPath("//html//*[@class=\"sr__group\"][2]/li[2]/a", onData: data).first
                break
            case .type3:
                //product fetch
                sideMenuLink = self.parseWithXPath("//html//div[@id=\"product-rating-reviews\"]//a", onData: data).first
				break
			case .type4:
				//product fetch
				sideMenuLink = self.parseWithXPath("//html//div[@id=\"host-slice\"]//a", onData: data).first
				break
            case .noParserAvailable:
                NSLog("Could not parse the Category for this product", "")
                sideMenuLink = nil
                break
            }
            
            var href = sideMenuLink?.attributes["href"] as? String ?? ""
            href = href.removingPercentEncoding ?? ""
            let queries = href.components(separatedBy: "&")
            
            for query in queries {
                if query.contains("tbs=") && query.contains("cat:") {
                    let r1 = query.range(of: "cat:")
					let r2 = query.range(of: ",")
                    if let r1 = r1, let r2 = r2, r2.lowerBound > r1.lowerBound {
                        catCode = query[r1.upperBound ..< r2.lowerBound]
					} else if let r1 = r1 {
						catCode = query[r1.upperBound ..< query.endIndex]
					}
                    break
                }
            }
            
            if catCode == nil {
                self.parserType = ParserType(rawValue: (self.parserType.rawValue+1) % ParserType.all.count)!
            }
            
        }
		if let category = ShopSearch.shared().categories?[catCode ?? ""] {
			return category
		} else if let catCode = catCode {
			return GoogleCategory(withId: catCode, name: "")
		} else {
			return nil
		}
    }
    
    func getProductId(_ urlPath:String?) -> String {
        let pId = urlPath?.components(separatedBy: "?")[0].components(separatedBy: "/").last ?? ""
		if Float(pId) != nil {
			return pId
		} else {
			return ""
		}
    }
    
    func stripHtmlTags(_ text:String) -> String {
		
        return text.replacingOccurrences(of: "<[^>]+>", with: "", options: String.CompareOptions.regularExpression, range: nil)
    }
    
    
}


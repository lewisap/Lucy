xquery version "1.0-ml";

module namespace c = "http://marklogic.com/roxy/controller/stocks";

import module namespace ch = "http://marklogic.com/roxy/controller-helper" at "/roxy/lib/controller-helper.xqy";
import module namespace req = "http://marklogic.com/roxy/request" at "/roxy/lib/request.xqy";


declare function c:list() as item()* {
  let $stocks := fn:collection("stock")//symbol/text()
  return ch:set-value("stocks", $stocks) 
};


declare function c:add() as item()* {
  let $ticker := req:get("ticker")
  let $_ := xdmp:log(xdmp:get-request-field-names())
  let $_ := xdmp:log(element TICKER { $ticker })
  return
    let $path := "/stocks/"||$ticker||".xml"
    let $doc := <ticker><symbol>{$ticker}</symbol></ticker>
    return (
      xdmp:document-insert($path, $doc, (), ("stock")),
      xdmp:add-response-header("location", "/stocks"),
      xdmp:set-response-code(302, "Moved temporarily"),
      ch:use-view(())
    )
};

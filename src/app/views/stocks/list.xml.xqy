xquery version "1.0-ml";


import module namespace vh   = "http://marklogic.com/roxy/view-helper" at "/roxy/lib/view-helper.xqy";

<Stocks>
  {
    for $stock in vh:get('stocks')
    return <stocks>{$stock}</stocks>
  }
</Stocks>
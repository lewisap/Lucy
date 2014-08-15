(:
Copyright 2014 MarkLogic Corporation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
:)
xquery version "1.0-ml";

module namespace l = "http://marklogic.com/roxy/lucy";

import module namespace user-conf = "http://marklogic.com/roxy/config" at "/app/config/config.xqy";
import module namespace req = "http://marklogic.com/roxy/request" at "/roxy/lib/request.xqy";



declare variable $controller as xs:string := req:get("controller");
declare variable $func as xs:string := req:get("func", "main", "type=xs:string");
declare variable $req-id := xdmp:request();

declare function l:profile-this-invocation() {
  fn:exists($user-conf:lucy-profile-controllers) and ($controller eq $user-conf:lucy-profile-controllers)
};

declare function l:qm-this-invocation() {
  fn:exists($user-conf:lucy-qm-controllers) and ($controller eq $user-conf:lucy-qm-controllers)
};

(:
  To enable Lucy profiling, define a variable called "lucy-profiling-enabled" and set it
  to all, or any not-nil value (like fn:true()) and then put the specific controllers to profile
  in a variable called lucy-profile-controllers.

  For example, to profile all invocations:
  declare variable conf:lucy-profiling-enabled := "all";

  To profile a specific controller called "my-controller":
  declare variable conf:lucy-profiling-enabled := fn:true();
  declare variable conf:lucy-profile-controllers := ("my-controller");

  To disable, either remove conf:lucy-profiling-enabled or:
  declare variable conf:lucy-profiling-enabled := ();

:)
declare function l:is-profiling-enabled() {
  fn:exists($user-conf:lucy-profiling-enabled) and (($user-conf:lucy-profiling-enabled = 'all') or l:profile-this-invocation())
};


(:
  To enable Lucy query metering, define a variable called "lucy-profiling-qn" and set it
  to all, or any not-nil value (like fn:true()) and then put the specific controllers subject
  to metering in a variable called lucy-qm-controllers.

  For example, to profile all invocations:
  declare variable conf:lucy-qm-enabled := "all";

  To profile a specific controller called "my-controller":
  declare variable conf:lucy-qm-enabled := fn:true();
  declare variable conf:lucy-qm-controllers := ("my-controller");

  To disable, either remove conf:lucy-qm-enabled or:
  declare variable conf:lucy-qm-enabled := ();
  
:)
declare function l:is-query-meters-enabled() {
  fn:exists($user-conf:lucy-qm-enabled) and (($user-conf:lucy-qm-enabled = 'all') or l:qm-this-invocation())
};

declare function l:store-profile-data($profile-data) {
  let $path := "/lucy/" || xs:string($req-id) || "/profile.xml"
  return (xdmp:document-insert($path, $profile-data, (), (
      "performance",
      "profile", 
      "http://controller/"||xs:string($controller), 
      "http://function/"||xs:string($func))), $path)
};

declare function l:store-qm-data($qm-data) {
  let $path := "/lucy/" || xs:string($req-id) || "/qm.xml"
  return (xdmp:document-insert($path, $qm-data, (), (
      "performance",
      "query-meters", 
      "http://controller/"||xs:string($controller), 
      "http://function/"||xs:string($func))), $path)
};



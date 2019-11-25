// Copyright (c)  WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import ballerina/log;
import ballerina/observe;
import ballerina/runtime;

boolean isTracingEnabled = getConfigBooleanValue(MICRO_GATEWAY_TRACING, ENABLED, false);
boolean isMetricsEnabled = getConfigBooleanValue(MICRO_GATEWAY_METRICS, ENABLED, false);

//metrics
public function initializeGauge(string name, string description, map<string> | () gaugeTags) returns observe:Gauge | () {
    if (isMetricsEnabled) {
        observe:Gauge localGauge = new (name, description, gaugeTags);
        registerGauge(localGauge);
        return localGauge;
    }
    else {
        return ();
    }
}

public function setGaugeDuration(int starting) returns float | () {
    if (isMetricsEnabled) {
        int ending = getCurrentTime();
        float latency = (ending - starting) * 1.0;
        return (latency);
    }
    else {
        return ();
    }
}

public function updateGauge(observe:Gauge | () localGauge, float | () latency) {
    if (isMetricsEnabled) {
        observe:Gauge gauge = <observe:Gauge>localGauge;
        float gauge_latency = <float>latency;
        gauge.setValue(gauge_latency);
    }
}

public function registerGauge(observe:Gauge gauge) {
    error? result = gauge.register();
    if (result is error) {
        log:printError("Error in registering Counter", err = result);
    }
}

public function gaugeTagDetails(http:Request request, http:FilterContext context, string category) returns map<string> | () {
    if (isMetricsEnabled) {
        map<string> gaugeTags = {"Category": category, "Method": request.method, "ServicePath": request.rawPath, "Service": context.getServiceName()};
        return gaugeTags;
    }
    else {
        return ();
    }
}

public function gaugeTagDetails_authn(http:Request request, string category) returns map<string> | () {
    if (isMetricsEnabled) {
        string serviceName = runtime:getInvocationContext().attributes[http:SERVICE_NAME].toString();
        map<string> gaugeTags = {"Category": category, "Method": request.method, "ServicePath": request.rawPath, "Service": serviceName};
        return gaugeTags;
    }
    else {
        return ();
    }
}

public function gaugeTagDetails_basicAuth(string category) returns map<string> | () {
    if (isMetricsEnabled) {
        string requestMethod = runtime:getInvocationContext().attributes[REQUEST_METHOD].toString();
        string requestRawPath = runtime:getInvocationContext().attributes[REQUEST_RAWPATH].toString();
        string serviceName = runtime:getInvocationContext().attributes[http:SERVICE_NAME].toString();
        map<string> gaugeTags = {"Category": category, "Method": requestMethod, "ServicePath": requestRawPath, "Service": serviceName};
        return gaugeTags;
    }
    else {
        return ();
    }
}

public function setGaugeTagInvocationContext(string attribute, map<string> | () gaugeTags) {
    if (isMetricsEnabled) {
        runtime:InvocationContext invocationContext = runtime:getInvocationContext();
        invocationContext.attributes[attribute] = gaugeTags;
    }
}

public function getGaugeTagInvocationContext(string attribute) returns map<string> | () {
    if (isMetricsEnabled) {
        return (<map<string>>runtime:getInvocationContext().attributes[attribute]);
    }
    else {
        return ();
    }
}

public function setLatencyInvocationContext(string attribute, float | () latency) {
    if (isMetricsEnabled) {
        runtime:InvocationContext invocationContext = runtime:getInvocationContext();
        invocationContext.attributes[attribute] = latency;
    }
}

public function getLatencyInvocationContext(string attribute) returns float | () {
    if (isMetricsEnabled) {
        return (<float>runtime:getInvocationContext().attributes[ANALYTIC_REQUEST_TIME]);
    }
    else {
        return ();
    }
}

public function calculateLatency(float | () req_latency, float | () latency) returns float | () {
    if (isMetricsEnabled) {
        return (<float>req_latency + <float>latency);
    }
    else {
        return ();
    }
}

//tracing
public function startSpan(string spanName) returns int | error | () {
    if (isTracingEnabled) {
        return observe:startSpan(spanName);
    }
    else {
        return ();
    }
}

public function finishSpan(string spanName, int | error | () spanId) {
    if (spanId is int) {
        error? result = observe:finishSpan(spanId);
        checkFinishSpanError(result, spanName);
    }
}

public function checkFinishSpanError(error? result, string spanName) {
    if (result is error) {
        log:printError(spanName, err = result);
    }
}

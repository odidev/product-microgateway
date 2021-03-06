/*
 *  Copyright (c) 2020, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 *  WSO2 Inc. licenses this file to you under the Apache License,
 *  Version 2.0 (the "License"); you may not use this file except
 *  in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an
 *  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied.  See the License for the
 *  specific language governing permissions and limitations
 *  under the License.
 */
package org.wso2.micro.gateway.tests.grpc;

import io.grpc.stub.StreamObserver;
import org.wso2.micro.gateway.tests.grpc.gen.TestRequest;
import org.wso2.micro.gateway.tests.grpc.gen.TestResponse;
import org.wso2.micro.gateway.tests.grpc.gen.TestServiceGrpc;

/*
 * This class contains the gRPC server (backend) implementation for the basic passthrough scenario.
 */
public class TestServiceImpl extends TestServiceGrpc.TestServiceImplBase{

    @Override
    public void testCall(TestRequest testRequest, StreamObserver<TestResponse> responseObserver) {
        String receivedReq = testRequest.getTestReqString();
        TestResponse response = TestResponse.newBuilder().setTestResString("response received :" + receivedReq).build();
        responseObserver.onNext(response);
        responseObserver.onCompleted();
    }
}

/****************************************************************************
 Copyright (c) 2018 Xiamen Yaji Software Co., Ltd.
 
 http://www.cocos2d-x.org
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#pragma once

#include <vector>
#include <map>
#include <stdlib.h>
#include <string>
#include "base/CCRef.h"
#include "2d/CCNode.h"
#include <spine/spine.h>

USING_NS_CC;
using namespace spine;

namespace spine {
    class AttachedNode : public Ref {
    public:
        AttachedNode(Node* _boneNode, Bone* _bone, int _boneIndex) {
            boneNode = _boneNode;
            bone = _bone;
            boneIndex = _boneIndex;
            toRemove = false;
        }

        Node* boneNode = nullptr;
        Bone* bone = nullptr;
        int boneIndex = -1;
        bool toRemove = false;
    };

    class RealTimeAttachUtil : public Ref
    {
    public:
        RealTimeAttachUtil() {}
        virtual ~RealTimeAttachUtil() {
            releaseAttachedNodes();
        }

        void init(Node* skeletonNode, Skeleton* skeleton);
        cocos2d::Vector<Node*> generateAttachedNodes(std::string& boneName);
        void destroyAttachedNodes(std::string& boneName);
        void destroyAllAttachedNodes();
        Node* buildBoneTree(Bone* bone);
        void syncAttachedNode();
        void associateAttachedNode();
        void releaseAttachedNodes();

    private:
        Node* prepareAttachNode();
        Node* getNodeByBoneIndex(const int boneIndex);
        Node* buildBoneAttachedNode(Bone* bone, const int boneIndex);
        void buildBoneRelation(Node* boneNode, Bone* bone, const int boneIndex);
        void sortAttachedNodes();
        void rebuildAttachedNodes();
        void markAttachedNodeToRemove(AttachedNode* rootNode);

    private:
        Node* _attachedRootNode = nullptr;
        Node* _skeletonNode = nullptr;
        Skeleton* _skeleton = nullptr;
        std::map<int, Node*> _boneIndexToNode;
        std::vector<AttachedNode*> _attachedNodes;
    };
}

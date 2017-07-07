//
//  ViewController.m
//  OhAR
//
//  Created by yangxinlei on 2017/7/6.
//  Copyright © 2017年 qunar. All rights reserved.
//

#import "ViewController.h"

typedef enum : NSUInteger {
    EarthRotateDirectionLeft,
    EarthRotateDirectionRight
} EarthRotateDirection;

@interface ViewController () <ARSCNViewDelegate>

@property (nonatomic, strong) IBOutlet ARSCNView *sceneView;
@property (nonatomic, strong) SCNNode *earthNode;
@property (nonatomic, strong) SCNNode *shipRotationNode;

@end

    
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Set the view's delegate
    self.sceneView.delegate = self;
    
    // Show statistics such as fps and timing information
    self.sceneView.showsStatistics = YES;
//    self.sceneView.debugOptions = ARSCNDebugOptionShowWorldOrigin | ARSCNDebugOptionShowFeaturePoints;
    
    // Create a new scene
    SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/earth.DAE"];
    self.earthNode = [[scene rootNode] childNodeWithName:@"earth" recursively:YES];
    [self.earthNode setPosition:SCNVector3Make(0, 0, -0.5)];
    
    SCNScene *shipScene = [SCNScene sceneNamed:@"art.scnassets/ship.scn"];
    SCNNode *shipNode = [[shipScene rootNode] childNodeWithName:@"ship" recursively:YES];
    [shipNode setPosition:SCNVector3Make(0, 0, -0.5)];
    [shipNode setRotation:SCNVector4Make(1, 0, 0, -M_PI_2)];
    [shipNode setScale:SCNVector3Make(0.1, 0.1, 0.1)];
    
    SCNParticleSystem *reactorParticle = [SCNParticleSystem particleSystemNamed:@"shipReactor.scnp" inDirectory:nil];
    [reactorParticle setBirthRate:140];
    [reactorParticle setParticleSize:0.005];
    [reactorParticle setParticleLifeSpan:0.09];
    [reactorParticle setParticleVelocity:0.13];
    SCNSphere *reactorGeo = [SCNSphere sphereWithRadius:0];
    
    SCNNode *leftReactorNode = [SCNNode nodeWithGeometry:reactorGeo];
    [leftReactorNode setPosition:SCNVector3Make(-0.03, 0.012, -0.16)];
    [leftReactorNode setRotation:SCNVector4Make(1, 0, 0, -M_PI_2)];
    [leftReactorNode addParticleSystem:reactorParticle];
    [shipNode addChildNode:leftReactorNode];
    
    SCNNode *rightReactorNode = [SCNNode nodeWithGeometry:reactorGeo];
    [rightReactorNode setPosition:SCNVector3Make(0.03, 0.012, -0.16)];
    [rightReactorNode setRotation:SCNVector4Make(1, 0, 0, -M_PI_2)];
    [rightReactorNode addParticleSystem:reactorParticle];
    [shipNode addChildNode:rightReactorNode];
    
    
    
    SCNSphere *sphereGeometry = [SCNSphere sphereWithRadius:0.01];
    self.shipRotationNode = [SCNNode nodeWithGeometry:sphereGeometry];
    [self.shipRotationNode setPosition:SCNVector3Make(0, 0, -0.5)];
    [self.shipRotationNode addChildNode:shipNode];
    [[scene rootNode] addChildNode:self.shipRotationNode];
    
    // Set the scene to the view
    self.sceneView.scene = scene;
    
    // 持续旋转shipRotationNode
    SCNAction *rAction = [SCNAction rotateByAngle:M_PI * 2 aroundAxis:SCNVector3Make(1, 0, 0) duration:20];
    SCNAction *kAction = [SCNAction repeatActionForever:rAction];
    [self.shipRotationNode runAction:kAction];
    
    
    // 处理拖动
    UIPanGestureRecognizer *panRecoginzer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    [panRecoginzer setMaximumNumberOfTouches:2];
    [panRecoginzer setMinimumNumberOfTouches:2];
    [self.sceneView addGestureRecognizer:panRecoginzer];
    // 处理左滑
    UISwipeGestureRecognizer *swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipped:)];
    [swipeLeftRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.sceneView addGestureRecognizer:swipeLeftRecognizer];
    // 处理右滑
    UISwipeGestureRecognizer *swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipped:)];
    [swipeRightRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.sceneView addGestureRecognizer:swipeRightRecognizer];
    
    // 处理长按
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [self.sceneView addGestureRecognizer:longPressRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Create a session configuration
    ARWorldTrackingSessionConfiguration *configuration = [ARWorldTrackingSessionConfiguration new];
    
    [configuration setPlaneDetection:ARPlaneDetectionHorizontal];
    // Run the view's session
    [self.sceneView.session runWithConfiguration:configuration];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Pause the view's session
    [self.sceneView.session pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - ARSCNViewDelegate

/*
// Override to create and configure nodes for anchors added to the view's session.
- (SCNNode *)renderer:(id<SCNSceneRenderer>)renderer nodeForAnchor:(ARAnchor *)anchor {
    SCNNode *node = [SCNNode new];
 
    // Add geometry to the node...
 
    return node;
}
*/

- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
    // Present an error message to the user
    
}

- (void)sessionWasInterrupted:(ARSession *)session {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
    
}

- (void)sessionInterruptionEnded:(ARSession *)session {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
    
}

#pragma mark - actions

- (void)rotateEarthBallWithDirection:(EarthRotateDirection)direction
{
    CGFloat rotateAngle = M_PI * 6;
    if (direction == EarthRotateDirectionLeft)
    {
        rotateAngle = - rotateAngle;
    }
    
    SCNAction *rAction = [SCNAction rotateByAngle:rotateAngle aroundAxis:SCNVector3Make(0, 1.0, 0) duration:3.0];
    [rAction setTimingMode:SCNActionTimingModeEaseOut];
    [self.earthNode runAction:rAction];
}

# pragma mark - touches

- (void)swipped:(UISwipeGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self.sceneView];
    NSArray<SCNHitTestResult *> *results = [self.sceneView hitTest:location options:nil];
    if (results && [results count] > 0)
    {
        SCNHitTestResult *result = results.firstObject;
        
        if ([result node] == self.earthNode)
        {
            [self rotateEarthBallWithDirection: (recognizer.direction == UISwipeGestureRecognizerDirectionLeft ? EarthRotateDirectionLeft : EarthRotateDirectionRight)];
        }
    }
}

- (void)longPressed:(UILongPressGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self.sceneView];
    NSArray<ARHitTestResult *> * results = [self.sceneView hitTest:location types:ARHitTestResultTypeFeaturePoint];
    
    if (results && [results count] > 0)
    {
        ARHitTestResult *anchor = [results firstObject];
        SCNMatrix4 hitPointTransform = SCNMatrix4FromMat4(anchor.worldTransform);
        SCNVector3 hitPointPosition = SCNVector3Make(hitPointTransform.m41, hitPointTransform.m42, hitPointTransform.m43);
        
        [self.earthNode setPosition:hitPointPosition];
        [self.shipRotationNode setPosition:hitPointPosition];
    }
}

- (void)panned:(UIPanGestureRecognizer *)recognizer
{
    static CGFloat prevTranslatedX = 0.0;
    CGPoint translatedPoint = [recognizer translationInView:self.sceneView];
    if ([recognizer state] == UIGestureRecognizerStateBegan)
    {
        prevTranslatedX = translatedPoint.x;
    }
    
    SCNVector4 rotateVector = SCNVector4Make(0, 1, 0, self.earthNode.rotation.w + (translatedPoint.x - prevTranslatedX) / 12.0);
    [self.earthNode setRotation:rotateVector];
    [self.shipRotationNode setRotation:rotateVector];
    prevTranslatedX = translatedPoint.x;
}


@end

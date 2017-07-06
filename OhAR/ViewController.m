//
//  ViewController.m
//  OhAR
//
//  Created by yangxinlei on 2017/7/6.
//  Copyright © 2017年 qunar. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <ARSCNViewDelegate>

@property (nonatomic, strong) IBOutlet ARSCNView *sceneView;

@property (nonatomic, strong) SCNNode *earthNode;

@end

    
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Set the view's delegate
    self.sceneView.delegate = self;
    
    // Show statistics such as fps and timing information
    self.sceneView.showsStatistics = YES;
    
    // Create a new scene
    SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/earth.DAE"];
    self.earthNode = [[scene rootNode] childNodeWithName:@"earth" recursively:YES];
    [self.earthNode setPosition:SCNVector3Make(0, 0, -1)];
    
    SCNAction *rAction = [SCNAction rotateByAngle:M_PI_2 aroundAxis:SCNVector3Make(0, 1.0, 0) duration:1];
    SCNAction *kAction = [SCNAction repeatActionForever:rAction];
    [self.earthNode runAction:kAction];
    
    // Set the scene to the view
    self.sceneView.scene = scene;
    
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipped:)];
    [self.sceneView addGestureRecognizer:swipeRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Create a session configuration
    ARWorldTrackingSessionConfiguration *configuration = [ARWorldTrackingSessionConfiguration new];
    
//    [configuration setPlaneDetection:ARPlaneDetectionHorizontal];
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

# pragma mark - touches
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInView:self.sceneView];
    NSArray<ARHitTestResult *> * results = [self.sceneView hitTest:location types:ARHitTestResultTypeFeaturePoint];
    
    if (results && [results count] > 0)
    {
        ARHitTestResult *anchor = [results firstObject];
        SCNMatrix4 hitPointTransform = SCNMatrix4FromMat4(anchor.worldTransform);
        SCNVector3 hitPointPosition = SCNVector3Make(hitPointTransform.m41, hitPointTransform.m42, hitPointTransform.m43);
        
        [self.earthNode setPosition:hitPointPosition];
    }
}

- (void)swipped:(UISwipeGestureRecognizer *)recognizer
{
    NSLog(@"🚩xxx--- %@ ---xxx🦋", @"swipped");
    if (recognizer.direction == UISwipeGestureRecognizerDirectionUp || recognizer.direction == UISwipeGestureRecognizerDirectionDown)
    {
        return ;
    }
    
    
    
}

@end

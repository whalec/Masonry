//
//  MASCompositeConstraintSpec.m
//  Masonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MASCompositeConstraint.h"
#import "MASViewConstraint.h"

@interface MASCompositeConstraint () <MASConstraintDelegate>

@property (nonatomic, strong) NSMutableArray *completedChildConstraints;
@property (nonatomic, strong) NSMutableArray *currentChildConstraints;
@property (nonatomic, assign) BOOL added;

@end

@interface MASViewConstraint ()

@property (nonatomic, assign) CGFloat layoutConstant;

@end

SpecBegin(MASCompositeConstraint)

__block id<MASConstraintDelegate> delegate;
__block UIView *superview;
__block UIView *view;
__block MASCompositeConstraint *composite;

beforeEach(^{
    composite = nil;
    delegate = mockProtocol(@protocol(MASConstraintDelegate));
    view = UIView.new;
    superview = UIView.new;
    [superview addSubview:view];
});

it(@"should create centerY and centerX children", ^{
    composite = [[MASCompositeConstraint alloc] initWithView:view type:MASCompositeViewConstraintTypeCenter];

    expect(composite.currentChildConstraints).to.haveCountOf(2);

    MASViewConstraint *viewConstraint = composite.currentChildConstraints[0];
    expect(viewConstraint.firstViewAttribute.view).to.beIdenticalTo(composite.view);
    expect(viewConstraint.firstViewAttribute.layoutAttribute).to.equal(NSLayoutAttributeCenterX);

    viewConstraint = composite.currentChildConstraints[1];
    expect(viewConstraint.firstViewAttribute.view).to.beIdenticalTo(composite.view);
    expect(viewConstraint.firstViewAttribute.layoutAttribute).to.equal(NSLayoutAttributeCenterY);
});

it(@"should create top, left, bottom, right children", ^{
    UIView *newView = UIView.new;
    composite = [[MASCompositeConstraint alloc] initWithView:view type:MASCompositeViewConstraintTypeEdges];
    composite.equalTo(newView);

    expect(composite.completedChildConstraints).to.haveCountOf(4);

    //top
    MASViewConstraint *viewConstraint = composite.completedChildConstraints[0];
    expect(viewConstraint.firstViewAttribute.view).to.beIdenticalTo(composite.view);
    expect(viewConstraint.firstViewAttribute.layoutAttribute).to.equal(NSLayoutAttributeTop);

    //left
    viewConstraint = composite.completedChildConstraints[1];
    expect(viewConstraint.firstViewAttribute.view).to.beIdenticalTo(composite.view);
    expect(viewConstraint.firstViewAttribute.layoutAttribute).to.equal(NSLayoutAttributeLeft);

    //bottom
    viewConstraint = composite.completedChildConstraints[2];
    expect(viewConstraint.firstViewAttribute.view).to.beIdenticalTo(composite.view);
    expect(viewConstraint.firstViewAttribute.layoutAttribute).to.equal(NSLayoutAttributeBottom);

    //right
    viewConstraint = composite.completedChildConstraints[3];
    expect(viewConstraint.firstViewAttribute.view).to.beIdenticalTo(composite.view);
    expect(viewConstraint.firstViewAttribute.layoutAttribute).to.equal(NSLayoutAttributeRight);
});

it(@"should create width and height children", ^{
    composite = [[MASCompositeConstraint alloc] initWithView:view type:MASCompositeViewConstraintTypeSize];
    expect(composite.currentChildConstraints).to.haveCountOf(2);

    MASViewConstraint *viewConstraint = composite.currentChildConstraints[0];
    expect(viewConstraint.firstViewAttribute.view).to.beIdenticalTo(composite.view);
    expect(viewConstraint.firstViewAttribute.layoutAttribute).to.equal(NSLayoutAttributeWidth);

    viewConstraint = composite.currentChildConstraints[1];
    expect(viewConstraint.firstViewAttribute.view).to.beIdenticalTo(composite.view);
    expect(viewConstraint.firstViewAttribute.layoutAttribute).to.equal(NSLayoutAttributeHeight);
});

it(@"should complete children", ^{
    composite = [[MASCompositeConstraint alloc] initWithView:view type:MASCompositeViewConstraintTypeSize];
    composite.delegate = delegate;
    UIView *newView = UIView.new;

    //first equality statement
    composite.equalTo(newView).sizeOffset(CGSizeMake(90, 30));

    [verify(delegate) addConstraint:(id)composite];

    expect(composite.completedChildConstraints).to.haveCountOf(2);
    expect(composite.currentChildConstraints).to.haveCountOf(2);

    MASViewConstraint *viewConstraint = composite.completedChildConstraints[0];
    expect(viewConstraint.secondViewAttribute.view).to.beIdenticalTo(newView);
    expect(viewConstraint.secondViewAttribute.layoutAttribute).to.equal(NSLayoutAttributeWidth);
    expect(viewConstraint.layoutConstant).to.equal(90);

    viewConstraint = composite.completedChildConstraints[1];
    expect(viewConstraint.secondViewAttribute.view).to.beIdenticalTo(newView);
    expect(viewConstraint.secondViewAttribute.layoutAttribute).to.equal(NSLayoutAttributeHeight);
    expect(viewConstraint.layoutConstant).to.equal(30);

    //chain another equality statement
    composite.greaterThanOrEqualTo(@6);
    expect(composite.completedChildConstraints).to.haveCountOf(4);
    expect(composite.currentChildConstraints).to.haveCountOf(2);

    viewConstraint = composite.completedChildConstraints[2];
    expect(viewConstraint.secondViewAttribute.view).to.beNil();
    expect(viewConstraint.secondViewAttribute.layoutAttribute).to.equal(0);
    expect(viewConstraint.layoutConstant).to.equal(6);

    viewConstraint = composite.completedChildConstraints[2];
    expect(viewConstraint.secondViewAttribute.view).to.beNil();
    expect(viewConstraint.secondViewAttribute.layoutAttribute).to.equal(0);
    expect(viewConstraint.layoutConstant).to.equal(6);

    //still referencing same view
    viewConstraint = composite.currentChildConstraints[0];
    expect(viewConstraint.firstViewAttribute.view).to.beIdenticalTo(composite.view);
    expect(viewConstraint.firstViewAttribute.layoutAttribute).to.equal(NSLayoutAttributeWidth);

    viewConstraint = composite.currentChildConstraints[1];
    expect(viewConstraint.firstViewAttribute.view).to.beIdenticalTo(composite.view);
    expect(viewConstraint.firstViewAttribute.layoutAttribute).to.equal(NSLayoutAttributeHeight);
});

it(@"should remove all on commit", ^{
    composite = [[MASCompositeConstraint alloc] initWithView:view type:MASCompositeViewConstraintTypeSize];
    composite.delegate = delegate;
    UIView *newView = UIView.new;
    [superview addSubview:newView];

    //first equality statement
    composite.equalTo(newView).sizeOffset(CGSizeMake(90, 30));

    [verify(delegate) addConstraint:(id)composite];

    expect(composite.completedChildConstraints).to.haveCountOf(2);
    expect(composite.currentChildConstraints).to.haveCountOf(2);

    [composite commit];

    expect(composite.completedChildConstraints).to.haveCountOf(0);
    expect(composite.currentChildConstraints).to.haveCountOf(0);
});

SpecEnd
//
//  ViewController.m
//  netrunnerapp
//
//  Created by Paul Clark on 7/27/15.
//  Copyright (c) 2015 Paul Clark. All rights reserved.
//

#import "ViewController.h"
#import <PureLayout.h>

@interface CardView : UIView
@property (nonatomic, strong) UILabel* accessOrderLabel;
@end

@implementation CardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.accessOrderLabel = [[UILabel alloc] init];
        self.accessOrderLabel.textAlignment = NSTextAlignmentCenter;
        self.accessOrderLabel.font = [UIFont systemFontOfSize:35];
        [self addSubview:self.accessOrderLabel];
        [self.accessOrderLabel autoCenterInSuperview];
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 1.f;
        self.layer.cornerRadius = 5;
    }
    return self;
}
@end

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *handSizeIncrementerButton;
@property (weak, nonatomic) IBOutlet UIButton *handSizeDecrementerButton;
@property (weak, nonatomic) IBOutlet UILabel *handSizeLabel;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UIButton *accessButton;
@property (weak, nonatomic) IBOutlet UIView *cardContainerView;
@property (nonatomic) NSUInteger currentHandSize;

@property (nonatomic) NSMutableOrderedSet* cardAccessOrder;
@property (nonatomic) NSMutableArray* cardViews;
@end

@implementation ViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.cardAccessOrder = [[NSMutableOrderedSet alloc] init];
        self.cardViews = [[NSMutableArray alloc] init];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.currentHandSize = 5;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self resetAccessedCardInformation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setCurrentHandSize:(NSUInteger)currentHandSize
{
    _currentHandSize = currentHandSize;
    
    //Reset Card amount
    self.handSizeLabel.text = [@(currentHandSize) stringValue];
    [self resetAccessedCardInformation];
}

-(void)resetAccessedCardInformation
{
    for (CardView* cardView in self.cardViews) {
        [cardView removeFromSuperview];
    }
    [self.cardViews removeAllObjects];
    [self.cardAccessOrder removeAllObjects];
    [self displayNumberOfCards:self.currentHandSize];
}

-(void)displayNumberOfCards:(NSUInteger)numberOfCards
{
    NSUInteger leftMargin = 10;
    NSUInteger xIndex = leftMargin;
    NSUInteger yIndex = 10;
    NSUInteger cardWidth = 100;
    NSUInteger cardHeight = 150;
    
    CardView* previousCardView;
    
    for (int cardIndex = 0; cardIndex < numberOfCards; cardIndex++) {
        CardView* cardView = [[CardView alloc] init];
        [cardView autoSetDimensionsToSize:CGSizeMake(cardWidth, cardHeight)];
        
        [self.cardContainerView addSubview:cardView];
        [self.cardViews addObject:cardView];
        
        [cardView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10];
        [cardView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10];
        
        if(cardIndex == 0) {
            [cardView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
        } else if(cardIndex == numberOfCards -1) {
            [cardView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
        }
        
        if(previousCardView) {
            [cardView autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:previousCardView withOffset:10];
        }
        
        previousCardView = cardView;
    }
}

-(void)redrawAccessInformOnCards
{
    NSArray* accessOrderArray = [self.cardAccessOrder array];
    
    NSUInteger accessCount = 1;
    for (NSNumber* accessIndex in accessOrderArray) {
        CardView* cardView = [self.cardViews objectAtIndex:[accessIndex unsignedIntegerValue]];
        cardView.accessOrderLabel.text = [@(accessCount) stringValue];
        accessCount+=1;
    }
}

-(void)performAnotherAccess
{
    
    NSUInteger nextAccessIndex = [self randomNumberBetween:0 andNumber:self.currentHandSize notWithinSet:[self.cardAccessOrder set]];
    if(nextAccessIndex != NSNotFound) {
        [self.cardAccessOrder addObject:@(nextAccessIndex)];
    }
    [self redrawAccessInformOnCards];
}

- (IBAction)onClearButtonPressed:(id)sender
{
    [self resetAccessedCardInformation];
}

- (IBAction)onAccessButtonPressed:(id)sender
{
    [self performAnotherAccess];
}

- (IBAction)onHandSizeIncrementerButtonPressed:(id)sender
{
    self.currentHandSize += 1;
    self.handSizeDecrementerButton.enabled = self.currentHandSize > 1;
}

- (IBAction)onHandSizeDecrementerButtonPressed:(id)sender
{
    self.currentHandSize -= 1;
    self.handSizeDecrementerButton.enabled = self.currentHandSize > 1;
}

-(NSUInteger)randomNumberBetween:(NSUInteger)firstNumber andNumber:(NSUInteger)secondNumber notWithinSet:(NSSet*)exclusionSet
{
    NSParameterAssert(secondNumber > firstNumber);
    if(secondNumber - firstNumber == [exclusionSet count]) {
        return NSNotFound;
    }
    
    NSUInteger randomNumber = [self randomNumberBetween:firstNumber andNumber:secondNumber];
    
    while([exclusionSet containsObject:@(randomNumber)]) {
        randomNumber = [self randomNumberBetween:firstNumber andNumber:secondNumber];
    }
    return randomNumber;
}


-(NSUInteger)randomNumberBetween:(NSUInteger)firstNumber andNumber:(NSUInteger)secondNumber
{
    NSParameterAssert(secondNumber > firstNumber);
    NSUInteger numberDifference = secondNumber-firstNumber;
    return arc4random_uniform((unsigned)numberDifference)+firstNumber;
}

@end

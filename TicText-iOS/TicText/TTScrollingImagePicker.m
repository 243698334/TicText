//
//  TTScrollingImagePicker.m
//  TicText
//
//  Created by Chengkan Huang on 4/17/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTScrollingImagePicker.h"
#import "TTScrollingLayout.h"
#import "TTScrollingImagePickerCell.h"

#define kImageSpacing 2.0

@interface TTScrollingImagePicker () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *imagesArray;
@property (nonatomic, strong) NSNumber *selectedIndex;

@end

@implementation TTScrollingImagePicker

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    TTScrollingLayout *flow = [[TTScrollingLayout alloc] init];
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flow.minimumLineSpacing = kImageSpacing;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flow];
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.allowsMultipleSelection = NO;
    collectionView.allowsSelection = YES;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.collectionViewLayout = flow;
    [collectionView registerClass:[TTScrollingImagePickerCell class] forCellWithReuseIdentifier:@"Cell"];

    [self addSubview:collectionView];
    self.collectionView = collectionView;
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(collectionView);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|" options:0 metrics:nil views:views]];
    
}

- (void)setImages:(NSMutableArray *)images;
{
    self.imagesArray = [images copy];
    
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    return self.imagesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    TTScrollingImagePickerCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.imageView.image = [self.imagesArray objectAtIndex:indexPath.row];
    return cell;
}

//TODO:override SupplymentaryElement for send button appear

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    [self toggleSelectionAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    [self toggleSelectionAtIndexPath:indexPath];
}

- (void)toggleSelectionAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger index = indexPath.row;
    NSNumber *path = @(index);
    
//    TTScrollingImagePickerCell *cell = (TTScrollingImagePickerCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    self.selectedIndex = path;

    //TODO: Manage internal selection state
    //blur effect?
    
    // Notify delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectionDidUpdateForPicker:)]) {
        [self.delegate selectionDidUpdateForPicker:self];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    UIImage *imageAtPath = [self.imagesArray objectAtIndex:indexPath.row];
    
    CGFloat imageHeight = imageAtPath.size.height;
    CGFloat viewHeight = collectionView.bounds.size.height;
    CGFloat scaleFactor = viewHeight/imageHeight;
    
    CGSize scaledSize = CGSizeApplyAffineTransform(imageAtPath.size, CGAffineTransformMakeScale(scaleFactor, scaleFactor));
    return scaledSize;
}

@end

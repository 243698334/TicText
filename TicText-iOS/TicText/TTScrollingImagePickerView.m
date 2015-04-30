//
//  TTScrollingImagePickerView
//  TicText
//
//  Created by Chengkan Huang on 4/17/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTScrollingImagePickerView.h"

#import <PureLayout/PureLayout.h>
#import "TTScrollingImagePickerCell.h"

#define kImageSpacing 2.0

@interface TTScrollingImagePickerView () <UICollectionViewDataSource, UICollectionViewDelegate, TTScrollingImagePickerCellDelegate>

@property (nonatomic, assign) BOOL addConstraints;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL needLoadMoreImages;
@property (nonatomic, strong) UIButton *imagePickerButton;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *imagesArray;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) TTScrollingImagePickerCell *selectedCell;

@property (nonatomic, strong) UIView *optionButtonsView;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic) BOOL optionViewIsShown;
@property (nonatomic, assign) CGFloat lastContentOffset;

@end

@implementation TTScrollingImagePickerView

- (id)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.flowLayout.minimumInteritemSpacing = kImageSpacing;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.flowLayout];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.allowsMultipleSelection = NO;
    self.collectionView.allowsSelection = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.collectionViewLayout = self.flowLayout;
    [self.collectionView registerClass:[TTScrollingImagePickerCell class] forCellWithReuseIdentifier:@"Cell"];
    [self addSubview:self.collectionView];
    
    
    self.imagePickerButton = [[UIButton alloc] init];
    [self.imagePickerButton setBackgroundColor:kTTUIPurpleColor];
    [self.imagePickerButton setAlpha:0.8];
    [self.imagePickerButton setImage:[UIImage imageNamed:@"ImagePickerIcon"] forState:UIControlStateNormal];
    [self.imagePickerButton.layer setMasksToBounds:YES];
    [self.imagePickerButton.layer setCornerRadius:25];
    [self.imagePickerButton addTarget:self
                               action:@selector(didTapImagePickerButton)
                     forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.imagePickerButton];
    
    self.needLoadMoreImages = YES;
    
    self.addConstraints = NO;
    [self setNeedsUpdateConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)updateConstraints {
    if (!self.addConstraints) {
        self.addConstraints = YES;
        [self.collectionView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
        [self.collectionView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self];
        [self.imagePickerButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self withOffset:-5 relation:NSLayoutRelationEqual];
        [self.imagePickerButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self withOffset:5 relation:NSLayoutRelationEqual];
        [self.imagePickerButton autoSetDimension:ALDimensionHeight toSize:50];
        [self.imagePickerButton autoSetDimension:ALDimensionWidth toSize:50];
    }
    
    [super updateConstraints];
}

- (void)didTapImagePickerButton {
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTScrollingImagePickerDidTapImagePickerButton object:nil];
}

- (void)setImages:(NSMutableArray *)images {
    self.imagesArray = images;
    [self.collectionView reloadData];
    self.isLoading = NO;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imagesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TTScrollingImagePickerCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"Cell"
                                                                                      forIndexPath:indexPath];
    [cell setImage:[self.imagesArray objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"deselect at %ld", indexPath.row);
    TTScrollingImagePickerCell *cell = (TTScrollingImagePickerCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [self removeEffectFromCell:cell];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"select at %ld", indexPath.row);
    self.selectedIndex = indexPath.row;
    TTScrollingImagePickerCell *cell = (TTScrollingImagePickerCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    if (self.optionViewIsShown) {
        [self removeEffectFromCell:cell];
    } else {
        [self addEffectToCell:cell];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.selectedCell) {
        [self removeEffectFromCell:self.selectedCell];
    }
    // reach the right end of the scrollView
    if (scrollView.contentOffset.x + scrollView.frame.size.width >= scrollView.contentSize.width) {
        if (!self.isLoading) {
            self.isLoading = YES;
            if (self.delegate) {
                [self.delegate needLoadMoreImagesForScrollingImagePicker:self];
            }
        }
    }
}

# pragma mark - TTScrollingImagePickerCellDelegate
- (void) didTapSendButtonInScrollingImagePickerCell:(TTScrollingImagePickerCell *)cell {
    NSLog(@"Send image at index %ld", self.selectedIndex);
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTScrollingUIImagePickerDidChooseImage
                                                        object:nil
                                                      userInfo:@{kTTScrollingUIImagePickerChosenImageKey : [self.imagesArray objectAtIndex:self.selectedIndex]}];
    [self removeEffectFromCell:cell];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UIImage *imageAtPath = [self.imagesArray objectAtIndex:indexPath.row];
    
    CGFloat imageHeight = imageAtPath.size.height;
    CGFloat viewHeight = collectionView.frame.size.height;
    CGFloat scaleFactor = viewHeight/imageHeight;
    
    CGSize scaledSize = CGSizeApplyAffineTransform(imageAtPath.size, CGAffineTransformMakeScale(scaleFactor, scaleFactor));
    scaledSize.height = MIN(viewHeight, scaledSize.height);
    return scaledSize;
}

#pragma mark - Helpers
- (void) removeEffectFromCell:(TTScrollingImagePickerCell *)cell {
    self.optionViewIsShown = NO;
    cell.delegate = nil;
    [cell hideOptionButtons];
    self.selectedCell = nil;
}

- (void) addEffectToCell:(TTScrollingImagePickerCell *)cell {
    self.optionViewIsShown = YES;
    cell.delegate = self;
    [cell showOptionButtons];
    self.selectedCell = cell;
}

@end

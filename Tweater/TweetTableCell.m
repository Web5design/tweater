//
//  TweetCell.m
//  Tweater
//
//  Created by Hyungjun Kim on 8/24/13.
//  Copyright (c) 2013 Hyungjun Kim. All rights reserved.
//

#import "TweetTableCell.h"

@implementation TweetTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.usernameLabel = [[UILabel alloc]init];
		self.usernameLabel.textAlignment = NSTextAlignmentLeft;
		self.usernameLabel.font = [UIFont systemFontOfSize:14];
		self.usernameLabel.textColor = [UIColor grayColor];
		self.tweetLabel = [[UILabel alloc]init];
		self.tweetLabel.textAlignment = NSTextAlignmentLeft;
		self.tweetLabel.font = [UIFont systemFontOfSize:10];
		self.tweetLabel.textColor = [UIColor grayColor];
		self.tweetLabel.numberOfLines = 0;
		[self.contentView addSubview:self.usernameLabel];
		[self.contentView addSubview:self.tweetLabel];
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	//Set Label Frames
	self.usernameLabel.frame = CGRectMake(5, 5, 320, 20);
	self.tweetLabel.frame = CGRectMake(5, 30, 320, 45);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

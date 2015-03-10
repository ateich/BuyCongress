//
//  PoliticianTableViewCell.m
//  MyCongress
//
//  Created by HackReactor on 3/9/15.
//  Copyright (c) 2015 HackReactor. All rights reserved.
//

#import "PoliticianTableViewCell.h"
#import "ColorScheme.h"

@implementation PoliticianTableViewCell{
    UILabel *name;
    UILabel *state;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UITableViewCell *cell = self;
        cell.backgroundColor = [UIColor clearColor];

        UIView *card = [[UIView alloc] init];
        card.translatesAutoresizingMaskIntoConstraints = NO;
        card.backgroundColor = [ColorScheme cardColor];
        [cell addSubview:card];

        NSNumber *leftMargin = @15;
        NSNumber *halfMargin = @([leftMargin intValue]/2);
        NSNumber *quarterMargin = @([halfMargin intValue]/2);

        NSDictionary *views = NSDictionaryOfVariableBindings(card);
        NSDictionary *metrics = @{@"leftMargin":leftMargin, @"topMargin":halfMargin, @"largeTopMargin":halfMargin, @"sideMargin":@10, @"quarterMargin":quarterMargin};

        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-largeTopMargin-[card]-0-|" options:0 metrics:metrics views:views]];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[card]-leftMargin-|" options:0 metrics:metrics views:views]];

        //Politician's Title and Name
        name = [[UILabel alloc] init];
        name.translatesAutoresizingMaskIntoConstraints = NO;
        [self setName];

        //Politician's Party and State
        state = [[UILabel alloc] init];
        state.translatesAutoresizingMaskIntoConstraints = NO;
        state.textColor = [UIColor grayColor];
        [self setState];

        [card addSubview:name];
        [card addSubview:state];
        views = NSDictionaryOfVariableBindings(name, state);

        [card addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topMargin-[name]-quarterMargin-[state]-topMargin-|" options:0 metrics:metrics views:views]];
        [card addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[name]-|" options:0 metrics:metrics views:views]];
        [card addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[state]-|" options:0 metrics:metrics views:views]];
    }
    return self;
}

- (void)setName{
    name.text = [NSString stringWithFormat:@"%@. %@ %@", _politician.title, _politician.firstName, _politician.lastName];
}

- (void)setPolitician:(Politician *)politician{
    _politician = politician;
    [self setName];
    [self setState];
}

- (void)setState{
    state.text = [NSString stringWithFormat:@"%@ - %@", _politician.party, _politician.state];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

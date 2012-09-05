//
//  SOFavoritesViewController.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOFavoritesViewController.h"
#import "SOHTTPClient.h"

#import "SOEventViewController.h"
#import "SOSpeakerViewController.h"

#import "SOEvent.h"
#import "SOSpeaker.h"

@interface SOFavoritesViewController () <NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *_fetchedResultsController;
    NSManagedObjectContext *moc;
}
- (void)refetchData;
@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) NSArray *speakers;
@end

@implementation SOFavoritesViewController
@synthesize segmentView = _segmentView;
@synthesize tableView = _tableView;
@synthesize segmentEventsBtn = _segmentEventsBtn;
@synthesize segmentSpeakersBtn = _segmentSpeakersBtn;
@synthesize events = _events;
@synthesize speakers = _speakers;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Favorites";
    _tableView.separatorColor = [UIColor colorWithWhite:0.85 alpha:1];
    
    if (DEMO) {
        _events = @[@"Talk 1",@"Talk 2",@"Talk 3",@"Talk 4",@"Talk 5",@"Talk 6",@"Talk 7",@"Talk 8",@"Talk 9",@"Talk 10",@"Talk 11",@"Talk 12"];
        _speakers = @[@"Speaker 1",@"Speaker 2",@"Speaker 3",@"Speaker 4",@"Speaker 5",@"Speaker 6",@"Speaker 7",@"Speaker 8",@"Speaker 9",@"Speaker 10",@"Speaker 11",@"Speaker 12"];
    }
    
    _segmentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"segment_bg"]];
    
    [self didSelectSegment:_segmentEventsBtn];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    moc = nil;
    _tableView = nil;
    _fetchedResultsController = nil;
    _segmentView = nil;
    _segmentEventsBtn = nil;
    _segmentSpeakersBtn = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _fetchedResultsController.delegate = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 58;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (DEMO) return (currentSegment == SOFavoritesSegmentTypeEvents) ? _events.count : _speakers.count;
    
    return [[[_fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentSegment == SOFavoritesSegmentTypeEvents) {
        NSString *cellIdentifier = @"EventCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            
            //        Background views
            UIView *bgColorView = [[UIView alloc] init];
            [bgColorView setBackgroundColor:[UIColor colorWithWhite:0.95f alpha:1.0f]];
            [cell setBackgroundView:bgColorView];
            
            UIView *bgColorViewSelected = [[UIView alloc] init];
            [bgColorViewSelected setBackgroundColor:[UIColor colorWithRed:0.051 green:0.643 blue:0.816 alpha:1]];
            [cell setSelectedBackgroundView:bgColorViewSelected];
            
            //        Text Label Setup
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:19.0f];
            cell.textLabel.textColor = [UIColor colorWithRed:13.0f/255.0f green:164.0f/255.0f blue:208.0f/255.0f alpha:1.0f];
            cell.textLabel.backgroundColor = bgColorView.backgroundColor;
            
            //        Detail Text Label Setup
            cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:12.0f];
            cell.detailTextLabel.textColor = [UIColor colorWithWhite:0.6f alpha:1.0f];
            cell.detailTextLabel.backgroundColor = bgColorView.backgroundColor;
            
            //        Accessory Image
            UIImage *accessoryImage = [UIImage imageNamed:@"list-arrow"];
            UIImageView *accImageView = [[UIImageView alloc] initWithImage:accessoryImage];
            [accImageView setFrame:CGRectMake(0, 0, 12, 17)];
            cell.accessoryView = accImageView;
        }
        
        //    Cell Content
        if (DEMO) {
            cell.textLabel.text = [_events objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = @"Today at 12:05PM, Room B202";
        } else {
            SOEvent *event = [_fetchedResultsController objectAtIndexPath:indexPath];
            cell.textLabel.text = event.title;
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"MMM. d 'at' h:mma"];
            NSString *dateString = [df stringFromDate:event.start];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@",dateString, event.location];
        }
        
        return cell;
    }   else if (currentSegment == SOFavoritesSegmentTypeSpeakers) {
        NSArray *cellAvatars = @[@"list-avatar-mo-nostar",@"list-avatar-jp-nostar",@"list-avatar-generic-nostar"];
        
        NSString *cellIdentifier = @"SpeakerCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            //        Background views
            UIView *bgColorView = [[UIView alloc] init];
            [bgColorView setBackgroundColor:[UIColor colorWithWhite:0.95f alpha:1.0f]];
            [cell setBackgroundView:bgColorView];
            
            UIView *bgColorViewSelected = [[UIView alloc] init];
            [bgColorViewSelected setBackgroundColor:[UIColor colorWithRed:0.051 green:0.643 blue:0.816 alpha:1]];
            [cell setSelectedBackgroundView:bgColorViewSelected];
            
            //        Text Label Setup
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:19.0f];
            cell.textLabel.textColor = [UIColor colorWithRed:13.0f/255.0f green:164.0f/255.0f blue:208.0f/255.0f alpha:1.0f];
            cell.textLabel.backgroundColor = bgColorView.backgroundColor;
            
            //        Accessory Image
            UIImage *accessoryImage = [UIImage imageNamed:@"list-arrow"];
            UIImageView *accImageView = [[UIImageView alloc] initWithImage:accessoryImage];
            [accImageView setFrame:CGRectMake(0, 0, 12, 17)];
            cell.accessoryView = accImageView;
        }
        
        //    Content
        if (DEMO) {
            cell.textLabel.text = [_speakers objectAtIndex:indexPath.row];
            cell.imageView.image = [UIImage imageNamed:[cellAvatars objectAtIndex:indexPath.row%cellAvatars.count]];
        } else {
            SOSpeaker *speaker = [_fetchedResultsController objectAtIndexPath:indexPath];
            cell.textLabel.text = speaker.name;
            cell.imageView.image = [UIImage imageNamed:[cellAvatars objectAtIndex:indexPath.row%cellAvatars.count]];
        }
        
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (currentSegment == SOFavoritesSegmentTypeEvents) {
        SOEventViewController *eventVC = [[SOEventViewController alloc] initWithNibName:@"SOEventViewController" bundle:nil];
        [self.navigationController pushViewController:eventVC animated:YES];
    } else if (currentSegment == SOFavoritesSegmentTypeSpeakers) {
        SOSpeakerViewController *speakerVC = [[SOSpeakerViewController alloc] initWithNibName:@"SOSpeakerViewController" bundle:nil];
        [self.navigationController pushViewController:speakerVC animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)didSelectSegment:(UIButton*)sender {
    if (sender == _segmentEventsBtn) {
        [_segmentSpeakersBtn setHighlighted:NO];
        currentSegment = SOFavoritesSegmentTypeEvents;
        
        if (!DEMO) {
            moc = [(id)[[UIApplication sharedApplication] delegate] managedObjectContext];
            [[SOHTTPClient sharedClient] getEventsWithSuccess:^(AFJSONRequestOperation *operation, NSDictionary *responseDict) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([[responseDict objectForKey:@"status"] isEqualToString:@"OK"]) {
                        NSArray *events = [[responseDict objectForKey:@"result"] objectForKey:@"events"];
                        
                        for (NSDictionary *eventDict in events) {
                            
                            SOEvent* event = nil;
                            
                            NSFetchRequest *request = [[NSFetchRequest alloc] init];
                            
                            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:moc];
                            [request setEntity:entity];
                            NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"remoteID == %d", [[eventDict objectForKey:@"id"] intValue]];
                            [request setPredicate:searchFilter];
                            
                            NSArray *results = [moc executeFetchRequest:request error:nil];
                            
                            if (results.count > 0) {
                                event = [results lastObject];
                            } else {
                                event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:moc];
                            }
                            
                            event.title = [eventDict objectForKey:@"title"];
                            event.remoteID = [NSNumber numberWithInt:[[eventDict objectForKey:@"id"] intValue]];
                            event.location = [eventDict objectForKey:@"location"];
                            event.textDescription = [eventDict objectForKey:@"description"];
                            event.code = [eventDict objectForKey:@"code"];
                            
                            //                        Dates
                            NSDateFormatter *df = [[NSDateFormatter alloc] init];
                            [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"]; // Sample date format: 2012-01-16T01:38:37.123Z
                            event.start = [df dateFromString:(NSString*)[eventDict objectForKey:@"start"]];
                            event.end = [df dateFromString:(NSString*)[eventDict objectForKey:@"end"]];
                        }
                        
                        NSError *error = nil;
                        if ([moc hasChanges] && ![moc save:&error]) {
                            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                        }
                    }
                });
            } failure:^(AFJSONRequestOperation *operation, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"getEvents failed");
                });
            }];
            
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
            NSSortDescriptor *sortOrder = [[NSSortDescriptor alloc] initWithKey:@"start" ascending:YES];
            
            [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortOrder]];
            
            _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:moc sectionNameKeyPath:nil cacheName:nil];
            _fetchedResultsController.delegate = self;
            [_fetchedResultsController performFetch:nil];
        }
    } else if (sender == _segmentSpeakersBtn) {
        [_segmentEventsBtn setHighlighted:NO];
        currentSegment = SOFavoritesSegmentTypeSpeakers;
        
        if (!DEMO) {
            moc = [(id)[[UIApplication sharedApplication] delegate] managedObjectContext];
            [[SOHTTPClient sharedClient] getSpeakersWithSuccess:^(AFJSONRequestOperation *operation, NSDictionary *responseDict) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([[responseDict objectForKey:@"status"] isEqualToString:@"OK"]) {
                        NSArray *speakers = [[responseDict objectForKey:@"result"] objectForKey:@"speakers"];
                        
                        for (NSDictionary *speakerDict in speakers) {
                            
                            SOSpeaker* speaker = nil;
                            
                            NSFetchRequest *request = [[NSFetchRequest alloc] init];
                            
                            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Speaker" inManagedObjectContext:moc];
                            [request setEntity:entity];
                            NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"remoteID == %d", [[speakerDict objectForKey:@"id"] intValue]];
                            [request setPredicate:searchFilter];
                            
                            NSArray *results = [moc executeFetchRequest:request error:nil];
                            
                            if (results.count > 0) {
                                speaker = [results lastObject];
                            } else {
                                speaker = [NSEntityDescription insertNewObjectForEntityForName:@"Speaker" inManagedObjectContext:moc];
                            }
                            
                            speaker.name = [speakerDict objectForKey:@"name"];
                            speaker.remoteID = [NSNumber numberWithInt:[[speakerDict objectForKey:@"id"] intValue]];
                        }
                        
                        NSError *error = nil;
                        if ([moc hasChanges] && ![moc save:&error]) {
                            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                        }
                    }
                });
            } failure:^(AFJSONRequestOperation *operation, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"getSpeakers failed");
                });
            }];
            
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Speaker"];
            NSSortDescriptor *nameInitialSortOrder = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
            
            [fetchRequest setSortDescriptors:[NSArray arrayWithObject:nameInitialSortOrder]];
            
            _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:moc sectionNameKeyPath:nil cacheName:nil];
            _fetchedResultsController.delegate = self;
            [_fetchedResultsController performFetch:nil];
        }
    }
    if (DEMO) [_tableView reloadData];
    [_tableView setContentOffset:CGPointMake(0, 0)];
    [self performSelector:@selector(doHighlight:) withObject:sender afterDelay:0];
}

- (void)doHighlight:(UIButton*)b {
    [b setHighlighted:YES];
}

#pragma mark - Core Data

- (void)refetchData {
    _fetchedResultsController.fetchRequest.resultType = NSManagedObjectResultType;
    [_fetchedResultsController performFetch:nil];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [_tableView reloadData];
}

@end

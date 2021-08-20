import AppKit
import EventKit
import AVFoundation

class StatusBarController {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    private var popover: NSPopover
    private var delegate: AppDelegate
    
    var eventStore = EKEventStore()
    var isInit: Bool = false
    var calendars: [EKCalendar] = Array()
    var av: AVAudioPlayer = AVAudioPlayer()

    init(popover: NSPopover, delegate: AppDelegate) {
        self.popover = popover
        self.delegate = delegate
        
        statusBar = NSStatusBar.init()
        statusItem = statusBar.statusItem(withLength: 28.0)
        
        if let statusBarButton = statusItem.button {
            statusBarButton.image = #imageLiteral(resourceName: "Image")
            statusBarButton.image?.size = NSSize(width: 18.0, height: 18.0)
            statusBarButton.image?.isTemplate = true
            statusBarButton.action = #selector(togglePopover(sender:))
            statusBarButton.target = self
        }
        
        if let audioAsset = NSDataAsset(name: "ring") {
            do {
                av = try AVAudioPlayer(data: audioAsset.data)
                getCalendarEvents()
                Timer.scheduledTimer(withTimeInterval: 300.0, repeats: true) {_ in
                    if(self.isInit) {
                        self.getCalendarEvents()
                    }
                }
                
                Timer.scheduledTimer(withTimeInterval: 40.0, repeats: true) {_ in
                    if(self.isInit) {
                        print("Pooling For New Events")
                        self.getNewEvents()
                    }
                }
            } catch {
                print("Error")
            }

        } else {
            print("Failed to load sound")
        }
        
    }
    
    
    @objc func togglePopover(sender: AnyObject) {
        if(popover.isShown) {
            hidePopover(sender)
        }
        else {
            showPopover(sender)
        }
    }
    
    func showPopover(_ sender: AnyObject) {
        if let statusBarButton = statusItem.button {
            popover.show(relativeTo: statusBarButton.bounds, of: statusBarButton, preferredEdge: NSRectEdge.maxY)
        }
    }
    
    
    func hidePopover(_ sender: AnyObject) {
        popover.performClose(sender)
    }
    
    func getCalendarEvents() {
        eventStore.requestAccess(to: .event, completion: {
                granted, error in
                if let error = error {
                   print("error")
                   return
                }
                if (granted) {
                    if(self.calendars.count == 0) {
                        let sources = self.eventStore.sources
                        for source in sources{
                            for calendar in source.calendars(for: .event){
                                self.calendars.append(calendar)
                            }
                        }
                    }

                    let minusOneHOur = Date(timeIntervalSinceNow: 0)
                    let plusOneHour = Date(timeIntervalSinceNow: 3600)
                    
                    
                    let predicate = self.eventStore.predicateForEvents(withStart: minusOneHOur, end: plusOneHour, calendars: self.calendars)

                    let events = self.eventStore.events(matching: predicate)

                    for event in events {
                        if(event.location != nil) {
                            if(!meetings.exists(link: event.location!, time: event.startDate)) {
                                let meeting = Meeting(time: event.startDate, title: event.title, zoomLink: event.location!);
                                
                                meetings.addMeeting(meeting: meeting)
                            } else {
                                print("didn't add")
                            }
                        }
                        
                    }
                    
                    self.isInit = true;
                    self.getNewEvents()
                }
        })
    }
    
    func getNewEvents() {
        if(meetings.meetings.count > 0) {
            let currentDate = Date(timeIntervalSinceNow: -30)
            let oneMinLater = Date(timeIntervalSinceNow: 40)
            
            let values: [Meeting] = meetings.getCurrentMeetings(start: currentDate, end: oneMinLater);
        
            nextMeeting.write(meetings: values)
            
            if(values.count > 0) {
                self.av.play()
                DispatchQueue.main.async {
                    if let statusBarButton = self.statusItem.button {
                        self.delegate.initView()
                        statusBarButton.performClick(self)
                    }
                }
            }
        }
    }
    
    func openedMeeting() {
        DispatchQueue.main.async {
            if let statusBarButton = self.statusItem.button {
                self.av.stop()
                statusBarButton.performClick(self)
            }
        }
    }
    
}

//
//  Configuration.swift
//  FritzCore
//
//  Created by Andrew Barba on 6/18/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//

@objc(FritzConfiguration)
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public class Configuration: NSObject {

  public static let `default` = Configuration(session: .default)

  @objc public let session: Session

  @objc public let sessionManager: SessionManager

  @objc(initWithSession:)
  public init(session: Session) {
    self.session = session
    self.sessionManager = SessionManager(session: session)
    super.init()
  }
}
